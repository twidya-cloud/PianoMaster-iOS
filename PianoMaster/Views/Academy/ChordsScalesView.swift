import SwiftUI

public struct ChordsScalesView: View {
    @ObservedObject var audioEngine: PianoAudioEngine
    @Binding var explorerMidis: Set<Int>

    @State private var selectedTab: Int = 0 // 0 = Chords, 1 = Scales
    
    // Chord state
    @State private var selectedChordRoot: String = "C"
    @State private var selectedChordType: String = "Major"

    // Scale state
    @State private var selectedScaleRoot: String = "C"
    @State private var selectedScaleId: String = "major"

    private let roots = Note.sharpNames

    public init(audioEngine: PianoAudioEngine, explorerMidis: Binding<Set<Int>>) {
        self.audioEngine = audioEngine
        self._explorerMidis = explorerMidis
    }

    private var currentChordNotes: [Note] {
        MusicTheory.chordNotes(root: selectedChordRoot, chordName: selectedChordType, octave: 4)
    }

    private var currentScaleNotes: [Note] {
        MusicTheory.scaleNotes(root: selectedScaleRoot, scaleId: selectedScaleId, octave: 4, count: 8)
    }

    public var body: some View {
        VStack(spacing: 12) {
            Picker("Mode", selection: $selectedTab) {
                Text("Chords Explorer").tag(0)
                Text("Scales & Modes").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            if selectedTab == 0 {
                // CHORD EXPLORER
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ROOT NOTE").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                            Picker("Root", selection: $selectedChordRoot) {
                                ForEach(roots, id: \.self) { r in Text(r).tag(r) }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .background(Color(white: 0.15))
                            .cornerRadius(8)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("CHORD TYPE").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                            Picker("Type", selection: $selectedChordType) {
                                ForEach(MusicTheory.standardChords) { c in
                                    Text("\(c.name) (\(c.symbol.isEmpty ? "maj" : c.symbol))").tag(c.name)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .background(Color(white: 0.15))
                            .cornerRadius(8)
                        }

                        Button(action: playChord) {
                            Label("Play Chord", systemImage: "play.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.orange)
                                .cornerRadius(8)
                        }
                    }

                    // Formula and Notes
                    HStack(spacing: 12) {
                        let chordDef = MusicTheory.standardChords.first { $0.name == selectedChordType }
                        Text("Intervals: \(chordDef?.intervals.map { "\($0)" }.joined(separator: " - ") ?? "")")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.cyan)

                        Spacer()

                        Text("Notes: \(currentChordNotes.map { $0.name }.joined(separator: ", "))")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(white: 0.1))
                    .cornerRadius(8)
                }
                .padding()
                .background(Color(white: 0.08))
                .cornerRadius(12)
                .onChange(of: selectedChordRoot) { _ in updateChordHighlights() }
                .onChange(of: selectedChordType) { _ in updateChordHighlights() }
            } else {
                // SCALE EXPLORER
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ROOT NOTE").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                            Picker("Root", selection: $selectedScaleRoot) {
                                ForEach(roots, id: \.self) { r in Text(r).tag(r) }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .background(Color(white: 0.15))
                            .cornerRadius(8)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("SCALE").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary)
                            Picker("Scale", selection: $selectedScaleId) {
                                ForEach(MusicTheory.standardScales) { s in Text(s.name).tag(s.id) }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .background(Color(white: 0.15))
                            .cornerRadius(8)
                        }

                        Button(action: playScaleArpeggio) {
                            Label("Play Scale", systemImage: "play.circle.fill")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }

                    let scaleDef = MusicTheory.standardScales.first { $0.id == selectedScaleId }
                    Text(scaleDef?.description ?? "")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Notes: \(currentScaleNotes.map { $0.name }.joined(separator: ", "))")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(white: 0.08))
                .cornerRadius(12)
                .onChange(of: selectedScaleRoot) { _ in updateScaleHighlights() }
                .onChange(of: selectedScaleId) { _ in updateScaleHighlights() }
            }
        }
        .onAppear {
            updateChordHighlights()
        }
    }

    private func updateChordHighlights() {
        explorerMidis = Set(currentChordNotes.map { $0.midi })
    }

    private func updateScaleHighlights() {
        explorerMidis = Set(currentScaleNotes.map { $0.midi })
    }

    private func playChord() {
        let notes = currentChordNotes
        for n in notes {
            audioEngine.playNote(midi: n.midi)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            for n in notes {
                audioEngine.stopNote(midi: n.midi)
            }
        }
    }

    private func playScaleArpeggio() {
        let notes = currentScaleNotes
        for (idx, n) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(idx) * 0.3) {
                audioEngine.playNote(midi: n.midi)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                    audioEngine.stopNote(midi: n.midi)
                }
            }
        }
    }
}
