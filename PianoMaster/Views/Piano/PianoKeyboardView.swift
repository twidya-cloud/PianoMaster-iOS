import SwiftUI

public struct PianoKeyboardView: View {
    @ObservedObject var audioEngine: PianoAudioEngine
    let activeMidis: Set<Int>
    let targetMidis: Set<Int>
    let explorerMidis: Set<Int>
    
    var onNotePressed: ((Int) -> Void)?
    var onNoteReleased: ((Int) -> Void)?

    @State private var labelMode: KeyLabelMode = .notes
    @State private var keyRangeOption: Int = 61 // 36, 61, 88
    @State private var octaveShift: Int = 0

    // Range boundaries
    private var range: (start: Int, end: Int) {
        switch keyRangeOption {
        case 36:
            return (48 + octaveShift * 12, 84 + octaveShift * 12) // C3 - C6
        case 88:
            return (21, 108) // A0 - C8
        default:
            return (36 + octaveShift * 12, 96 + octaveShift * 12) // C2 - C7
        }
    }

    private let whiteKeyWidth: CGFloat = 40.0
    private let whiteKeyHeight: CGFloat = 160.0
    private let blackKeyWidth: CGFloat = 26.0
    private let blackKeyHeight: CGFloat = 100.0

    public init(
        audioEngine: PianoAudioEngine,
        activeMidis: Set<Int>,
        targetMidis: Set<Int> = [],
        explorerMidis: Set<Int> = [],
        onNotePressed: ((Int) -> Void)? = nil,
        onNoteReleased: ((Int) -> Void)? = nil
    ) {
        self.audioEngine = audioEngine
        self.activeMidis = activeMidis
        self.targetMidis = targetMidis
        self.explorerMidis = explorerMidis
        self.onNotePressed = onNotePressed
        self.onNoteReleased = onNoteReleased
    }

    private var allNotesInRange: [Note] {
        let (s, e) = range
        return (s...e).map { Note(midi: $0) }
    }

    private var whiteNotesInRange: [Note] {
        allNotesInRange.filter { !$0.isBlackKey }
    }

    private var blackNotesInRange: [Note] {
        allNotesInRange.filter { $0.isBlackKey }
    }

    public var body: some View {
        VStack(spacing: 8) {
            // Piano Control Strip (Octave shift, Sustain pedal, Labels, Size)
            HStack(spacing: 12) {
                // Octave Shift
                HStack(spacing: 4) {
                    Button(action: { octaveShift = max(-2, octaveShift - 1) }) {
                        Image(systemName: "minus")
                            .font(.system(size: 11, weight: .bold))
                            .frame(width: 28, height: 28)
                            .background(Color(white: 0.2))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }

                    Text("Oct: \(octaveShift > 0 ? "+\(octaveShift)" : "\(octaveShift)")")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(width: 50)

                    Button(action: { octaveShift = min(2, octaveShift + 1) }) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                            .frame(width: 28, height: 28)
                            .background(Color(white: 0.2))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                }

                // Sustain Pedal Button
                Button(action: {
                    audioEngine.isSustainPedalDown.toggle()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: audioEngine.isSustainPedalDown ? "pianokeys.fill" : "pianokeys")
                        Text("Pedal")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(audioEngine.isSustainPedalDown ? Color.orange : Color(white: 0.2))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .shadow(color: audioEngine.isSustainPedalDown ? Color.orange.opacity(0.6) : .clear, radius: 6)
                }

                Spacer()

                // Key Label Picker
                Picker("Labels", selection: $labelMode) {
                    ForEach(KeyLabelMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 170)

                // Key Count Picker
                Picker("Range", selection: $keyRangeOption) {
                    Text("36").tag(36)
                    Text("61").tag(61)
                    Text("88").tag(88)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 120)
            }
            .padding(.horizontal, 12)

            // Scrollable Virtual Piano Keyboard
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        // 1. White Keys Row
                        HStack(spacing: 1) {
                            ForEach(whiteNotesInRange) { note in
                                PianoKeyView(
                                    note: note,
                                    isPressed: activeMidis.contains(note.midi),
                                    isTarget: targetMidis.contains(note.midi),
                                    isExplorerHighlight: explorerMidis.contains(note.midi),
                                    labelMode: labelMode
                                )
                                .frame(width: whiteKeyWidth, height: whiteKeyHeight)
                                .id(note.midi)
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { _ in
                                            if !activeMidis.contains(note.midi) {
                                                pressNote(note.midi)
                                            }
                                        }
                                        .onEnded { _ in
                                            releaseNote(note.midi)
                                        }
                                )
                            }
                        }

                        // 2. Black Keys Positioned Above White Keys
                        ForEach(blackNotesInRange) { blackNote in
                            let offset = calculateBlackKeyOffset(for: blackNote)

                            PianoKeyView(
                                note: blackNote,
                                isPressed: activeMidis.contains(blackNote.midi),
                                isTarget: targetMidis.contains(blackNote.midi),
                                isExplorerHighlight: explorerMidis.contains(blackNote.midi),
                                labelMode: labelMode
                            )
                            .frame(width: blackKeyWidth, height: blackKeyHeight)
                            .offset(x: offset)
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in
                                        if !activeMidis.contains(blackNote.midi) {
                                            pressNote(blackNote.midi)
                                        }
                                    }
                                    .onEnded { _ in
                                        releaseNote(blackNote.midi)
                                    }
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 6)
                }
                .onAppear {
                    // Scroll to Middle C (60)
                    proxy.scrollTo(60, anchor: .center)
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color(white: 0.06))
        .cornerRadius(14)
    }

    private func calculateBlackKeyOffset(for note: Note) -> CGFloat {
        // Find preceding white note index in the range
        guard let precedingWhiteIndex = whiteNotesInRange.firstIndex(where: { $0.midi == note.midi - 1 }) else {
            return 0
        }
        // Black key centers over the line between preceding white key and succeeding white key
        let leftEdge = CGFloat(precedingWhiteIndex + 1) * (whiteKeyWidth + 1) - (blackKeyWidth / 2)
        return leftEdge
    }

    private func pressNote(_ midi: Int) {
        audioEngine.playNote(midi: midi)
        onNotePressed?(midi)
    }

    private func releaseNote(_ midi: Int) {
        audioEngine.stopNote(midi: midi)
        onNoteReleased?(midi)
    }
}
