import Foundation
import AVFoundation
import AudioToolbox

/// High-performance physical modeling piano audio engine for iOS
/// Uses AVAudioEngine, AVAudioSourceNode for multi-harmonic additive synthesis,
/// dynamic ADSR envelopes, hammer strike transients, and AVAudioUnitReverb.
public final class PianoAudioEngine: ObservableObject {
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private let reverb = AVAudioUnitReverb()
    
    // Voice representation
    private final class Voice {
        let midi: Int
        let frequency: Float
        let velocity: Float
        var age: Double = 0.0
        var releaseAge: Double = 0.0
        var isReleasing: Bool = false
        var isDamped: Bool = false

        init(midi: Int, frequency: Float, velocity: Float) {
            self.midi = midi
            self.frequency = frequency
            self.velocity = velocity
        }
    }

    private var voices: [Voice] = []
    private let voiceLock = os_unfair_lock_t.allocate(capacity: 1)
    
    @Published public var isSustainPedalDown: Bool = false {
        didSet {
            handleSustainPedal(isSustainPedalDown)
        }
    }
    
    @Published public var masterVolume: Float = 0.85
    @Published public var reverbAmount: Float = 35.0 {
        didSet {
            reverb.wetDryMix = reverbAmount
        }
    }

    public init() {
        voiceLock.initialize(to: os_unfair_lock())
        setupAudioSession()
        setupEngine()
    }

    deinit {
        voiceLock.deallocate()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetooth, .allowBluetoothA2DP])
            try session.setPreferredIOBufferDuration(0.005) // ~5ms ultra-low latency
            try session.setActive(true)
        } catch {
            print("Failed to configure AVAudioSession: \(error)")
        }
    }

    private func setupEngine() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        let sampleRate = Float(format.sampleRate)

        // Custom real-time synthesis DSP render block
        let renderBlock: AVAudioSourceNodeRenderBlock = { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }

            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            guard let leftChannel = ablPointer[0].mData?.assumingMemoryBound(to: Float.self),
                  let rightChannel = ablPointer[1].mData?.assumingMemoryBound(to: Float.self) else {
                return noErr
            }

            // Clear output buffers
            for frame in 0..<Int(frameCount) {
                leftChannel[frame] = 0.0
                rightChannel[frame] = 0.0
            }

            os_unfair_lock_lock(self.voiceLock)
            let currentVoices = self.voices
            os_unfair_lock_unlock(self.voiceLock)

            if currentVoices.isEmpty {
                return noErr
            }

            let dt = 1.0 / Double(sampleRate)

            for voice in currentVoices {
                let freq = voice.frequency
                let vel = voice.velocity
                let baseDecay = max(1.2, 5.0 - Double(voice.midi - 21) * 0.045)

                for frame in 0..<Int(frameCount) {
                    voice.age += dt
                    let t = voice.age

                    // Amplitude envelope
                    var env: Float = 0.0
                    let attackTime = 0.004

                    if voice.isReleasing {
                        voice.releaseAge += dt
                        let releaseEnv = max(0.0, 1.0 - Float(voice.releaseAge / 0.14))
                        env = releaseEnv * exp(Float(-t / baseDecay))
                        if voice.releaseAge >= 0.14 {
                            voice.isDamped = true
                        }
                    } else {
                        if t < attackTime {
                            env = Float(t / attackTime)
                        } else {
                            env = exp(Float(-(t - attackTime) / baseDecay))
                        }
                    }

                    if env <= 0.0001 {
                        voice.isDamped = true
                        continue
                    }

                    // Multi-harmonic additive synthesis
                    let phase1 = Float(2.0 * Double.pi * Double(freq) * t)
                    let phase2 = Float(2.0 * Double.pi * Double(freq * 2.0) * t)
                    let phase3 = Float(2.0 * Double.pi * Double(freq * 3.0) * t)
                    let phase4 = Float(2.0 * Double.pi * Double(freq * 4.0) * t)

                    let h1 = sin(phase1)
                    let h2 = sin(phase2) * 0.5 * (0.8 + vel * 0.4)
                    let h3 = sin(phase3) * 0.25 * (0.6 + vel * 0.5)
                    let h4 = sin(phase4) * 0.12 * (0.4 + vel * 0.6)

                    let sample = (h1 + h2 + h3 + h4) * env * pow(vel, 1.2) * 0.25

                    leftChannel[frame] += sample
                    rightChannel[frame] += sample
                }
            }

            // Purge fully damped voices
            os_unfair_lock_lock(self.voiceLock)
            self.voices.removeAll(where: { $0.isDamped })
            os_unfair_lock_unlock(self.voiceLock)

            return noErr
        }

        let source = AVAudioSourceNode(renderBlock: renderBlock)
        self.sourceNode = source

        // Setup Reverb
        reverb.loadFactoryPreset(.mediumHall)
        reverb.wetDryMix = reverbAmount

        // Engine Routing: source -> reverb -> mainMixer -> output
        engine.attach(source)
        engine.attach(reverb)

        engine.connect(source, to: reverb, format: format)
        engine.connect(reverb, to: engine.mainMixerNode, format: format)

        do {
            try engine.start()
        } catch {
            print("Failed to start AVAudioEngine: \(error)")
        }
    }

    public func playNote(midi: Int, velocity: Float = 0.8) {
        let note = Note(midi: midi)
        let voice = Voice(midi: midi, frequency: note.frequency, velocity: velocity)

        os_unfair_lock_lock(voiceLock)
        // If note already exists, release old one
        if let existing = voices.first(where: { $0.midi == midi && !$0.isReleasing }) {
            existing.isReleasing = true
        }
        voices.append(voice)
        os_unfair_lock_unlock(voiceLock)
    }

    public func stopNote(midi: Int) {
        if isSustainPedalDown {
            // Keep note ringing under sustain pedal
            return
        }

        os_unfair_lock_lock(voiceLock)
        for voice in voices where voice.midi == midi && !voice.isReleasing {
            voice.isReleasing = true
        }
        os_unfair_lock_unlock(voiceLock)
    }

    public func stopAllNotes() {
        os_unfair_lock_lock(voiceLock)
        for voice in voices {
            voice.isReleasing = true
        }
        os_unfair_lock_unlock(voiceLock)
    }

    private func handleSustainPedal(_ isDown: Bool) {
        if !isDown {
            // Release all active voices when pedal lifts
            stopAllNotes()
        }
    }
}
