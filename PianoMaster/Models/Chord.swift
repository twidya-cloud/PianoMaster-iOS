import Foundation

public struct ChordDefinition: Identifiable {
    public var id: String { name }
    public let name: String
    public let symbol: String
    public let intervals: [Int] // semitone offsets from root

    public init(name: String, symbol: String, intervals: [Int]) {
        self.name = name
        self.symbol = symbol
        self.intervals = intervals
    }
}

public struct IdentifiedChord: Equatable {
    public let fullName: String
    public let symbol: String
    public let root: String
    public let typeName: String
    public let bassNote: String
    public let notes: [Note]

    public var displayString: String {
        return fullName
    }
}

public class MusicTheory {
    public static let standardChords: [ChordDefinition] = [
        ChordDefinition(name: "Major", symbol: "", intervals: [0, 4, 7]),
        ChordDefinition(name: "Minor", symbol: "m", intervals: [0, 3, 7]),
        ChordDefinition(name: "Dominant 7th", symbol: "7", intervals: [0, 4, 7, 10]),
        ChordDefinition(name: "Major 7th", symbol: "maj7", intervals: [0, 4, 7, 11]),
        ChordDefinition(name: "Minor 7th", symbol: "m7", intervals: [0, 3, 7, 10]),
        ChordDefinition(name: "Diminished", symbol: "dim", intervals: [0, 3, 6]),
        ChordDefinition(name: "Diminished 7th", symbol: "dim7", intervals: [0, 3, 6, 9]),
        ChordDefinition(name: "Half-Diminished", symbol: "m7b5", intervals: [0, 3, 6, 10]),
        ChordDefinition(name: "Augmented", symbol: "aug", intervals: [0, 4, 8]),
        ChordDefinition(name: "Suspended 2nd", symbol: "sus2", intervals: [0, 2, 7]),
        ChordDefinition(name: "Suspended 4th", symbol: "sus4", intervals: [0, 5, 7]),
        ChordDefinition(name: "Add 9", symbol: "add9", intervals: [0, 4, 7, 14]),
        ChordDefinition(name: "Major 6th", symbol: "6", intervals: [0, 4, 7, 9]),
        ChordDefinition(name: "Minor 6th", symbol: "m6", intervals: [0, 3, 7, 9]),
        ChordDefinition(name: "Power Chord", symbol: "5", intervals: [0, 7])
    ]

    /// Identify chord in real-time from a collection of active MIDI note numbers
    public static func identifyChord(from activeMidis: Set<Int>) -> IdentifiedChord? {
        guard !activeMidis.isEmpty else { return nil }

        let sortedMidis = Array(activeMidis).sorted()
        let notes = sortedMidis.map { Note(midi: $0) }

        if sortedMidis.count == 1 {
            let n = notes[0]
            return IdentifiedChord(
                fullName: "\(n.baseName) (\(n.name))",
                symbol: n.baseName,
                root: n.baseName,
                typeName: "Single Note",
                bassNote: n.baseName,
                notes: notes
            )
        }

        let pitchClasses = Array(Set(sortedMidis.map { $0 % 12 }))
        let lowestMidi = sortedMidis[0]
        let bassPC = lowestMidi % 12
        let bassName = Note.sharpNames[bassPC]

        // Test each pitch class as potential root
        for root in 0..<12 {
            let rootName = Note.sharpNames[root]
            let relativePCs = pitchClasses.map { ($0 - root + 12) % 12 }.sorted()

            for chordDef in standardChords {
                let chordPCs = Array(Set(chordDef.intervals.map { $0 % 12 })).sorted()

                if relativePCs == chordPCs {
                    let isInversion = bassPC != root
                    let fullName = "\(rootName) \(chordDef.name)\(isInversion ? " / \(bassName)" : "")"
                    let symbol = "\(rootName)\(chordDef.symbol)\(isInversion ? "/\(bassName)" : "")"

                    return IdentifiedChord(
                        fullName: fullName,
                        symbol: symbol,
                        root: rootName,
                        typeName: chordDef.name,
                        bassNote: bassName,
                        notes: notes
                    )
                }
            }
        }

        // If no named triad/7th matches, display as note cluster
        let names = notes.map { $0.baseName }.joined(separator: " - ")
        return IdentifiedChord(
            fullName: names,
            symbol: names,
            root: bassName,
            typeName: "Cluster",
            bassNote: bassName,
            notes: notes
        )
    }

    /// Generate notes for a specific chord root and definition
    public static func chordNotes(root: String, chordName: String, octave: Int = 4) -> [Note] {
        guard let rootIndex = Note.sharpNames.firstIndex(of: root) else { return [] }
        let chordDef = standardChords.first { $0.name.lowercased() == chordName.lowercased() } ?? standardChords[0]
        let baseMidi = (octave + 1) * 12 + rootIndex

        return chordDef.intervals.map { Note(midi: baseMidi + $0) }
    }
}
