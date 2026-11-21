import SwiftUI

public enum KeyLabelMode: String, CaseIterable, Identifiable {
    case notes = "Notes"
    case solfege = "Solfège"
    case none = "None"

    public var id: String { rawValue }
}

public struct PianoKeyView: View {
    let note: Note
    let isPressed: Bool
    let isTarget: Bool
    let isExplorerHighlight: Bool
    let labelMode: KeyLabelMode

    public init(
        note: Note,
        isPressed: Bool,
        isTarget: Bool = false,
        isExplorerHighlight: Bool = false,
        labelMode: KeyLabelMode = .notes
    ) {
        self.note = note
        self.isPressed = isPressed
        self.isTarget = isTarget
        self.isExplorerHighlight = isExplorerHighlight
        self.labelMode = labelMode
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            if note.isBlackKey {
                // Black Key
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(
                        isPressed
                            ? LinearGradient(colors: [Color(white: 0.15), Color(white: 0.05)], startPoint: .top, endPoint: .bottom)
                            : (isTarget
                               ? LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .top, endPoint: .bottom)
                               : (isExplorerHighlight
                                  ? LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .top, endPoint: .bottom)
                                  : LinearGradient(colors: [Color(white: 0.25), Color(white: 0.1), Color(white: 0.05)], startPoint: .top, endPoint: .bottom)))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(isTarget ? Color.yellow : (isPressed ? Color.cyan : Color.white.opacity(0.1)), lineWidth: 1)
                    )
                    .shadow(color: isTarget ? Color.yellow.opacity(0.8) : (isPressed ? Color.cyan.opacity(0.6) : Color.black.opacity(0.5)), radius: isTarget || isPressed ? 8 : 4, y: 3)
            } else {
                // White Key
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(
                        isPressed
                            ? LinearGradient(colors: [Color(white: 0.85), Color(white: 0.75)], startPoint: .top, endPoint: .bottom)
                            : (isTarget
                               ? LinearGradient(colors: [Color(red: 1.0, green: 0.95, blue: 0.6), Color(red: 1.0, green: 0.8, blue: 0.2)], startPoint: .top, endPoint: .bottom)
                               : (isExplorerHighlight
                                  ? LinearGradient(colors: [Color(red: 0.7, green: 0.85, blue: 1.0), Color(red: 0.4, green: 0.7, blue: 1.0)], startPoint: .top, endPoint: .bottom)
                                  : LinearGradient(colors: [.white, Color(white: 0.96), Color(white: 0.88)], startPoint: .top, endPoint: .bottom)))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(isTarget ? Color.yellow : (isPressed ? Color.cyan : Color.gray.opacity(0.4)), lineWidth: 1)
                    )
                    .shadow(color: isTarget ? Color.yellow.opacity(0.8) : (isPressed ? Color.cyan.opacity(0.5) : Color.black.opacity(0.2)), radius: isTarget || isPressed ? 8 : 2, y: 2)
            }

            // Key Label & Middle C pip
            VStack(spacing: 4) {
                if note.midi == 60 {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 5, height: 5)
                        .shadow(color: .red, radius: 3)
                }

                if labelMode != .none {
                    Text(labelMode == .notes ? note.name : note.solfegeName)
                        .font(.system(size: note.isBlackKey ? 8 : 10, weight: .bold, design: .rounded))
                        .foregroundColor(note.isBlackKey ? .white.opacity(0.8) : (isPressed ? .cyan : Color(white: 0.3)))
                }
            }
            .padding(.bottom, 6)
        }
        .offset(y: isPressed ? 2 : 0)
    }
}
