import SwiftUI

public struct ContentView: View {
    @StateObject private var audioEngine = PianoAudioEngine()
    @StateObject private var midiManager = MIDIManager()

    // Active state
    @State private var activeMidis: Set<Int> = []
    @State private var targetMidis: Set<Int> = []
    @State private var explorerMidis: Set<Int> = []
    
    // Navigation Tab
    @State private var selectedTab: Int = 0

    // Song Academy State
    @State private var selectedSong: Song = SongLibrary.songs[0]
    @State private var gameMode: GameMode = .wait
    @State private var handType: HandType = .both
    @State private var songSpeed: Double = 1.0
    @State private var isSongPlaying: Bool = false

    // Recording State
    @State private var isRecording: Bool = false
    @State private var recordedEvents: [RecordedEvent] = []
    @State private var recordStartTime: Date = Date()

    // Identified Chord
    private var activeChord: IdentifiedChord? {
        MusicTheory.identifyChord(from: activeMidis)
    }

    public init() {}

    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.07, blue: 0.12), Color(red: 0.08, green: 0.11, blue: 0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 8) {
                // Header Bar
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "pianokeys")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.cyan)
                        Text("PianoMaster")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    // MIDI Badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(midiManager.isMidiConnected ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)
                            .shadow(color: midiManager.isMidiConnected ? .green : .clear, radius: 4)

                        Text(midiManager.isMidiConnected ? (midiManager.connectedDevices.first ?? "MIDI Connected") : "No MIDI")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(white: 0.12))
                    .cornerRadius(20)

                    // Volume slider
                    HStack(spacing: 4) {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Slider(value: $audioEngine.masterVolume, in: 0...1)
                            .frame(width: 60)
                            .tint(.cyan)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)

                // Navigation Tabs
                HStack(spacing: 6) {
                    TabButton(title: "Songs", icon: "music.note", isSelected: selectedTab == 0) { selectedTab = 0 }
                    TabButton(title: "Chords", icon: "music.quarternote.3", isSelected: selectedTab == 1) { selectedTab = 1 }
                    TabButton(title: "Staff", icon: "text.book.closed.fill", isSelected: selectedTab == 2) { selectedTab = 2 }
                    TabButton(title: "Ear", icon: "ear.badge.waveform", isSelected: selectedTab == 3) { selectedTab = 3 }
                    TabButton(title: "Studio", icon: "record.circle", isSelected: selectedTab == 4) { selectedTab = 4 }
                }
                .padding(.horizontal, 16)

                // Upper Content Area (Tab Driven)
                Group {
                    switch selectedTab {
                    case 0:
                        // LEARN SONGS & FALLING NOTES
                        VStack(spacing: 8) {
                            // Song Controls Bar
                            HStack(spacing: 12) {
                                Picker("Song", selection: $selectedSong) {
                                    ForEach(SongLibrary.songs) { song in
                                        Text("\(song.title) (\(song.difficulty))").tag(song)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .background(Color(white: 0.15))
                                .cornerRadius(8)

                                Picker("Mode", selection: $gameMode) {
                                    ForEach(GameMode.allCases) { mode in
                                        Text(mode.rawValue).tag(mode)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .background(Color(white: 0.15))
                                .cornerRadius(8)

                                Button(action: { isSongPlaying.toggle() }) {
                                    Label(isSongPlaying ? "Pause" : "Play", systemImage: isSongPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 13, weight: .bold))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }

                                Spacer()

                                HStack(spacing: 4) {
                                    Text("Speed:").font(.system(size: 11)).foregroundColor(.secondary)
                                    Slider(value: $songSpeed, in: 0.5...1.5, step: 0.1)
                                        .frame(width: 70)
                                        .tint(.cyan)
                                    Text(String(format: "%.1fx", songSpeed))
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(.cyan)
                                        .frame(width: 32)
                                }
                            }
                            .padding(.horizontal, 14)

                            // Falling Notes Game Visualizer
                            FallingNotesView(
                                audioEngine: audioEngine,
                                currentSong: selectedSong,
                                activeMidis: activeMidis,
                                selectedMode: $gameMode,
                                selectedHand: $handType,
                                speed: $songSpeed,
                                isPlaying: $isSongPlaying,
                                onTargetNotesChanged: { targets in
                                    self.targetMidis = targets
                                },
                                onSongCompleted: { score, hits, total in
                                    print("Song complete! Score: \(score)")
                                }
                            )
                            .padding(.horizontal, 14)
                        }

                    case 1:
                        ChordsScalesView(audioEngine: audioEngine, explorerMidis: $explorerMidis)
                            .padding(.horizontal, 14)

                    case 2:
                        SightReadingView(audioEngine: audioEngine, activeMidis: activeMidis)
                            .padding(.horizontal, 14)

                    case 3:
                        EarTrainingView(audioEngine: audioEngine, activeMidis: activeMidis)
                            .padding(.horizontal, 14)

                    case 4:
                        StudioView(audioEngine: audioEngine, isRecording: $isRecording, recordedEvents: $recordedEvents)
                            .padding(.horizontal, 14)

                    default:
                        EmptyView()
                    }
                }

                Spacer(minLength: 4)

                // Real-Time Chord HUD Banner
                ChordHUDView(activeChord: activeChord)
                    .padding(.horizontal, 14)

                // Bottom Virtual Piano Keyboard
                PianoKeyboardView(
                    audioEngine: audioEngine,
                    activeMidis: activeMidis,
                    targetMidis: targetMidis,
                    explorerMidis: explorerMidis,
                    onNotePressed: { midi in
                        activeMidis.insert(midi)
                        recordNoteEvent(midi: midi, isNoteOn: true)
                    },
                    onNoteReleased: { midi in
                        activeMidis.remove(midi)
                        recordNoteEvent(midi: midi, isNoteOn: false)
                    }
                )
                .padding(.horizontal, 10)
                .padding(.bottom, 6)
            }
        }
        .onAppear {
            setupMidiCallbacks()
        }
    }

    private func setupMidiCallbacks() {
        midiManager.onNoteOn = { midi, velocity in
            audioEngine.playNote(midi: midi, velocity: velocity)
            activeMidis.insert(midi)
            recordNoteEvent(midi: midi, isNoteOn: true, velocity: velocity)
        }

        midiManager.onNoteOff = { midi in
            audioEngine.stopNote(midi: midi)
            activeMidis.remove(midi)
            recordNoteEvent(midi: midi, isNoteOn: false)
        }

        midiManager.onPedalChange = { isDown in
            audioEngine.isSustainPedalDown = isDown
        }
    }

    private func recordNoteEvent(midi: Int, isNoteOn: Bool, velocity: Float = 0.8) {
        guard isRecording else { return }
        let elapsed = Date().timeIntervalSince(recordStartTime)
        recordedEvents.append(
            RecordedEvent(
                type: isNoteOn ? "noteOn" : "noteOff",
                midi: midi,
                time: elapsed,
                velocity: velocity
            )
        )
    }
}

private struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(white: 0.15))
            .foregroundColor(isSelected ? .white : .secondary)
            .cornerRadius(8)
        }
    }
}
