import SwiftUI

public struct EarTrainingView: View {
    @ObservedObject var audioEngine: PianoAudioEngine
    let activeMidis: Set<Int>

    @State private var mysteryNoteMidi: Int = 60
    @State private var score: Int = 0
    @State private var streak: Int = 0
    @State private var feedbackText: String = "Tap 'New Mystery Note' to test your ear!"
    @State private var feedbackColor: Color = .secondary

    public init(audioEngine: PianoAudioEngine, activeMidis: Set<Int>) {
        self.audioEngine = audioEngine
        self.activeMidis = activeMidis
    }

    public var body: some View {
        VStack(spacing: 14) {
            Text("👂 Pitch Memory & Ear Trainer")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            Text("Listen to the pitch and press the matching key on the piano!")
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            // Play & Replay Buttons
            HStack(spacing: 16) {
                Button(action: startNewRound) {
                    Label("New Mystery Note", systemImage: "headphones")
                        .font(.system(size: 13, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: replayNote) {
                    Label("Replay Sound", systemImage: "arrow.clockwise")
                        .font(.system(size: 13, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(white: 0.2))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            // Stats
            HStack(spacing: 24) {
                HStack(spacing: 4) {
                    Text("SCORE:").font(.system(size: 11, weight: .bold)).foregroundColor(.secondary)
                    Text("\(score)").font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundColor(.cyan)
                }

                HStack(spacing: 4) {
                    Text("STREAK:").font(.system(size: 11, weight: .bold)).foregroundColor(.secondary)
                    Text("\(streak)🔥").font(.system(size: 15, weight: .heavy, design: .rounded)).foregroundColor(.orange)
                }
            }

            // Feedback Banner
            Text(feedbackText)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(feedbackColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color(white: 0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(white: 0.08))
        .cornerRadius(14)
        .onChange(of: activeMidis) { newActive in
            checkEarAnswer(newActive)
        }
    }

    private func startNewRound() {
        // Range: C4 (60) to C5 (72)
        mysteryNoteMidi = Int.random(in: 60...72)
        feedbackText = "🎵 Listen carefully... click the matching key!"
        feedbackColor = .cyan
        replayNote()
    }

    private func replayNote() {
        audioEngine.playNote(midi: mysteryNoteMidi)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            audioEngine.stopNote(midi: mysteryNoteMidi)
        }
    }

    private func checkEarAnswer(_ active: Set<Int>) {
        guard let played = active.first else { return }
        let target = Note(midi: mysteryNoteMidi)

        if played == mysteryNoteMidi {
            score += 100
            streak += 1
            feedbackText = "✅ CORRECT! It was \(target.name)!"
            feedbackColor = .green
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                startNewRound()
            }
        } else {
            streak = 0
            let diff = played - mysteryNoteMidi
            let hint = diff > 0 ? "too high" : "too low"
            feedbackText = "❌ Not quite! That note was \(hint). Try again!"
            feedbackColor = .red
        }
    }
}
