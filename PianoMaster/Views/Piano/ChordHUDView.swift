import SwiftUI

public struct ChordHUDView: View {
    let activeChord: IdentifiedChord?

    public init(activeChord: IdentifiedChord?) {
        self.activeChord = activeChord
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("CHORD:")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.secondary)
                .tracking(1)

            if let chord = activeChord {
                Text(chord.fullName)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.cyan)
                    .shadow(color: Color.cyan.opacity(0.5), radius: 6)

                Text(chord.notes.map { $0.baseName }.joined(separator: " - "))
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            } else {
                Text("Play keys to detect chord")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(white: 0.1).opacity(0.85))
        .cornerRadius(10)
    }
}
