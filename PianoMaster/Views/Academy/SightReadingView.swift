import SwiftUI

public struct SightReadingView: View {
    @ObservedObject var audioEngine: PianoAudioEngine
    let activeMidis: Set<Int>

    @State private var targetMidi: Int = 60 // Middle C
    @State private var score: Int = 0
    @State private var streak: Int = 0
    @State private var feedbackText: String = "Play the note shown on the staff!"
    @State private var feedbackColor: Color = .secondary

    public init(audioEngine: PianoAudioEngine, activeMidis: Set<Int>) {
        self.audioEngine = audioEngine
        self.activeMidis = activeMidis
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Header stats
            HStack(spacing: 16) {
                Text("𝄞 Sight Reading Trainer")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                HStack(spacing: 12) {
                    Text("Score: \(score)").font(.system(size: 12, weight: .bold)).foregroundColor(.cyan)
                    Text("Streak: \(streak)🔥").font(.system(size: 12, weight: .bold)).foregroundColor(.orange)
                }

                Button("Skip ⏩", action: nextRandomNote)
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(white: 0.2))
                    .cornerRadius(6)
            }
            .padding(.horizontal)

            // Musical Staff Canvas
            Canvas { context, size in
                drawMusicalStaff(context: context, size: size, targetMidi: targetMidi)
            }
            .frame(height: 180)
            .background(Color(white: 0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )

            // Feedback Message
            Text(feedbackText)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(feedbackColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(white: 0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(white: 0.08))
        .cornerRadius(14)
        .onAppear {
            nextRandomNote()
        }
        .onChange(of: activeMidis) { newActive in
            checkUserAnswer(newActive)
        }
    }

    private func nextRandomNote() {
        // Random note from C4 (60) to G5 (79) on Treble Clef
        targetMidi = Int.random(in: 60...79)
        feedbackText = "Find and play this note on the piano!"
        feedbackColor = .secondary
    }

    private func checkUserAnswer(_ active: Set<Int>) {
        guard let played = active.first else { return }
        let targetNote = Note(midi: targetMidi)

        if played == targetMidi {
            score += 100
            streak += 1
            feedbackText = "🎯 EXCELLENT! That was \(targetNote.name)!"
            feedbackColor = .green
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                nextRandomNote()
            }
        } else {
            streak = 0
            let playedNote = Note(midi: played)
            feedbackText = "❌ Played \(playedNote.name). Try again!"
            feedbackColor = .red
        }
    }

    private func drawMusicalStaff(context: GraphicsContext, size: CGSize, targetMidi: Int) {
        let w = size.width
        let h = size.height
        let lineSpacing: CGFloat = 12.0
        let trebleCenterY = h * 0.45

        // Draw 5 staff lines
        for i in 0..<5 {
            let y = trebleCenterY + CGFloat(i - 2) * lineSpacing
            var path = Path()
            path.move(to: CGPoint(x: 24, y: y))
            path.addLine(to: CGPoint(x: w - 24, y: y))
            context.stroke(path, with: .color(Color.white.opacity(0.2)), lineWidth: 1.5)
        }

        // Draw Clef Indicator Label
        context.draw(
            Text("𝄞 Treble Clef").font(.system(size: 14, weight: .bold)).foregroundColor(.indigo),
            at: CGPoint(x: 70, y: trebleCenterY - lineSpacing * 2.8)
        )

        // Calculate Note Position
        let note = Note(midi: targetMidi)
        let E4_STEP = 30 // E4 is bottom line of treble staff
        let stepDiff = CGFloat(note.staffStep - E4_STEP)
        let staffBottomY = trebleCenterY + lineSpacing * 2
        let noteY = staffBottomY - stepDiff * (lineSpacing / 2.0)
        let noteX = w * 0.52

        // Ledger line for Middle C or low/high notes
        if targetMidi == 60 {
            var ledger = Path()
            ledger.move(to: CGPoint(x: noteX - 16, y: noteY))
            ledger.addLine(to: CGPoint(x: noteX + 16, y: noteY))
            context.stroke(ledger, with: .color(.cyan), lineWidth: 2)
        }

        // Draw Note Head
        let ellipseRect = CGRect(x: noteX - 8, y: noteY - 5.5, width: 16, height: 11)
        var noteHead = Path(ellipseIn: ellipseRect)
        context.fill(noteHead, with: .color(.cyan))

        // Stem
        var stem = Path()
        stem.move(to: CGPoint(x: noteX + 7, y: noteY))
        stem.addLine(to: CGPoint(x: noteX + 7, y: noteY - 32))
        context.stroke(stem, with: .color(.cyan), lineWidth: 2)

        // Accidental if black key
        if note.isBlackKey {
            context.draw(
                Text("♯").font(.system(size: 16, weight: .bold)).foregroundColor(.cyan),
                at: CGPoint(x: noteX - 16, y: noteY)
            )
        }
    }
}
