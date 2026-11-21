import SwiftUI

public enum GameMode: String, CaseIterable, Identifiable {
    case wait = "Wait For Me (Practice)"
    case flow = "Flow (Play Along)"
    case demo = "Demo (Watch & Listen)"

    public var id: String { rawValue }
}

public struct FallingNotesView: View {
    @ObservedObject var audioEngine: PianoAudioEngine
    let currentSong: Song
    let activeMidis: Set<Int>

    @Binding var selectedMode: GameMode
    @Binding var selectedHand: HandType
    @Binding var speed: Double
    @Binding var isPlaying: Bool
    
    var onTargetNotesChanged: ((Set<Int>) -> Void)?
    var onSongCompleted: ((Int, Int, Int) -> Void)?

    @State private var songTime: Double = -1.5 // 1.5s countdown
    @State private var score: Int = 0
    @State private var streak: Int = 0
    @State private var multiplier: Int = 1
    @State private var hitCount: Int = 0
    @State private var feedbackText: String = ""
    @State private var feedbackColor: Color = .white
    @State private var feedbackTimer: Double = 0.0

    // Tracking note hit states
    @State private var noteHitStates: [UUID: Bool] = [:]

    private var filteredNotes: [SongNote] {
        if selectedHand == .both {
            return currentSong.notes
        }
        return currentSong.notes.filter { $0.hand == selectedHand }
    }

    public init(
        audioEngine: PianoAudioEngine,
        currentSong: Song,
        activeMidis: Set<Int>,
        selectedMode: Binding<GameMode>,
        selectedHand: Binding<HandType>,
        speed: Binding<Double>,
        isPlaying: Binding<Bool>,
        onTargetNotesChanged: ((Set<Int>) -> Void)? = nil,
        onSongCompleted: ((Int, Int, Int) -> Void)? = nil
    ) {
        self.audioEngine = audioEngine
        self.currentSong = currentSong
        self.activeMidis = activeMidis
        self._selectedMode = selectedMode
        self._selectedHand = selectedHand
        self._speed = speed
        self._isPlaying = isPlaying
        self.onTargetNotesChanged = onTargetNotesChanged
        self.onSongCompleted = onSongCompleted
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Stats HUD
            HStack(spacing: 16) {
                StatPill(label: "SCORE", value: "\(score)")
                StatPill(label: "STREAK", value: "\(streak)🔥")
                StatPill(label: "MULT", value: "\(multiplier)x")
                StatPill(label: "ACCURACY", value: "\(accuracyPercentage)%")
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(white: 0.12))

            // Canvas Falling Notes Game Stage
            GeometryReader { geometry in
                TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
                    Canvas { context, size in
                        drawGame(context: context, size: size, now: timeline.date)
                    }
                    .background(Color(red: 0.05, green: 0.07, blue: 0.12))
                    .onChange(of: timeline.date) { _ in
                        if isPlaying {
                            updateGameState(dt: 1.0 / 60.0)
                        }
                    }
                }
                .overlay(
                    // Feedback text
                    VStack {
                        if feedbackTimer > 0 {
                            Text(feedbackText)
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(feedbackColor)
                                .shadow(color: feedbackColor.opacity(0.8), radius: 10)
                                .transition(.scale.combined(with: .opacity))
                        }
                        if isPlaying && songTime < 0 {
                            Text("Ready: \(Int(ceil(-songTime)))")
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundColor(.cyan)
                                .shadow(color: .cyan, radius: 12)
                        }
                    }
                )
            }
            .frame(height: 220)
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .onChange(of: activeMidis) { newActive in
            handleUserKeystroke(newActive)
        }
        .onChange(of: currentSong.id) { _ in
            resetGame()
        }
    }

    private var accuracyPercentage: Int {
        let total = filteredNotes.count
        guard total > 0 else { return 100 }
        return Int(round((Double(hitCount) / Double(total)) * 100.0))
    }

    private func resetGame() {
        songTime = -1.5
        score = 0
        streak = 0
        multiplier = 1
        hitCount = 0
        noteHitStates.removeAll()
        feedbackText = ""
    }

    private func updateGameState(dt: Double) {
        let hitLineTime = songTime
        var currentTargets: Set<Int> = []
        var shouldHoldForWaitMode = false

        for note in filteredNotes {
            let timeDiff = note.time - hitLineTime
            let isHit = noteHitStates[note.id] ?? false

            if timeDiff <= 0.08 && timeDiff >= -note.duration {
                if !isHit {
                    currentTargets.insert(note.midi)
                    if selectedMode == .wait && hitLineTime >= note.time - 0.03 {
                        shouldHoldForWaitMode = true
                    }
                }
            }

            // Demo mode autoplay
            if selectedMode == .demo && !isHit && timeDiff <= 0 && timeDiff > -0.05 {
                noteHitStates[note.id] = true
                audioEngine.playNote(midi: note.midi)
                DispatchQueue.main.asyncAfter(deadline: .now() + note.duration) {
                    audioEngine.stopNote(midi: note.midi)
                }
            }
        }

        onTargetNotesChanged?(currentTargets)

        if !shouldHoldForWaitMode {
            songTime += dt * speed
        }

        if feedbackTimer > 0 {
            feedbackTimer -= dt
        }

        // Song end check
        if let last = filteredNotes.last, songTime > last.time + last.duration + 1.5 {
            isPlaying = false
            onSongCompleted?(score, hitCount, filteredNotes.count)
        }
    }

    private func handleUserKeystroke(_ activeKeys: Set<Int>) {
        guard isPlaying && selectedMode != .demo else { return }

        for note in filteredNotes {
            guard activeKeys.contains(note.midi) else { continue }
            if noteHitStates[note.id] == true { continue }

            let timeDiff = abs(note.time - songTime)
            let tolerance = selectedMode == .wait ? 0.35 : 0.22

            if timeDiff <= tolerance || (selectedMode == .wait && songTime >= note.time - 0.1 && songTime <= note.time + note.duration + 0.2) {
                noteHitStates[note.id] = true
                hitCount += 1
                streak += 1
                multiplier = min(4, 1 + streak / 5)

                let pts = timeDiff < 0.08 ? 100 : 50
                score += pts * multiplier

                feedbackText = timeDiff < 0.08 ? "PERFECT!" : "GOOD!"
                feedbackColor = timeDiff < 0.08 ? .yellow : .cyan
                feedbackTimer = 0.8
                break
            }
        }
    }

    private func drawGame(context: GraphicsContext, size: CGSize, now: Date) {
        let w = size.width
        let h = size.height
        let hitLineY = h - 6.0
        let lookAheadSeconds = 3.5
        let pixelsPerSecond = (h - 20) / lookAheadSeconds

        // Draw hit line
        var path = Path()
        path.move(to: CGPoint(x: 0, y: hitLineY))
        path.addLine(to: CGPoint(x: w, y: hitLineY))
        context.stroke(path, with: .color(Color.cyan.opacity(0.8)), lineWidth: 3)

        // Draw falling notes
        let minMidi = 36
        let maxMidi = 96
        let totalKeys = maxMidi - minMidi + 1
        let keyWidth = w / CGFloat(totalKeys)

        for note in filteredNotes {
            let timeUntilHit = note.time - songTime
            let noteHeight = max(16.0, CGFloat(note.duration * pixelsPerSecond))
            let noteBottom = hitLineY - CGFloat(timeUntilHit * pixelsPerSecond)
            let noteTop = noteBottom - noteHeight

            guard noteBottom >= 0 && noteTop <= h else { continue }

            let keyIndex = note.midi - minMidi
            let x = CGFloat(keyIndex) * keyWidth + 1
            let width = max(4.0, keyWidth - 2)

            let isHit = noteHitStates[note.id] ?? false
            let noteColor: Color = isHit ? .green : (note.hand == .left ? .orange : .cyan)

            let rect = CGRect(x: x, y: noteTop, width: width, height: noteHeight)
            let roundedPath = Path(roundedRect: rect, cornerRadius: 4)

            context.fill(roundedPath, with: .color(noteColor.opacity(0.85)))
            context.stroke(roundedPath, with: .color(.white.opacity(0.6)), lineWidth: 1)
        }
    }
}

private struct StatPill: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(white: 0.2))
        .cornerRadius(6)
    }
}
