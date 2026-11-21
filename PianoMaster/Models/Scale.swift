import Foundation

public struct ScaleDefinition: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let intervals: [Int] // semitone intervals from root
    public let description: String

    public init(id: String, name: String, intervals: [Int], description: String) {
        self.id = id
        self.name = name
        self.intervals = intervals
        self.description = description
    }
}

extension MusicTheory {
    public static let standardScales: [ScaleDefinition] = [
        ScaleDefinition(id: "major", name: "Major (Ionian)", intervals: [0, 2, 4, 5, 7, 9, 11], description: "Bright, triumphant, fundamental Western scale."),
        ScaleDefinition(id: "natural_minor", name: "Natural Minor (Aeolian)", intervals: [0, 2, 3, 5, 7, 8, 10], description: "Melancholic, emotive, classic minor tonality."),
        ScaleDefinition(id: "harmonic_minor", name: "Harmonic Minor", intervals: [0, 2, 3, 5, 7, 8, 11], description: "Exotic and dramatic with an augmented 2nd interval."),
        ScaleDefinition(id: "pentatonic_major", name: "Major Pentatonic", intervals: [0, 2, 4, 7, 9], description: "Versatile 5-note scale, sounds great over any major key."),
        ScaleDefinition(id: "pentatonic_minor", name: "Minor Pentatonic", intervals: [0, 3, 5, 7, 10], description: "Essential foundation for rock, blues, and pop solos."),
        ScaleDefinition(id: "blues", name: "Blues Scale", intervals: [0, 3, 5, 6, 7, 10], description: "Expressive with the soulful 'blue note' flat-fifth."),
        ScaleDefinition(id: "dorian", name: "Dorian Mode", intervals: [0, 2, 3, 5, 7, 9, 10], description: "Smooth jazz minor scale with an upbeat natural 6th."),
        ScaleDefinition(id: "mixolydian", name: "Mixolydian Mode", intervals: [0, 2, 4, 5, 7, 9, 10], description: "Dominant 7th feel, classic rock and blues sound.")
    ]

    /// Generate scale notes for a given root note, scale ID, and octave
    public static func scaleNotes(root: String, scaleId: String, octave: Int = 4, count: Int = 8) -> [Note] {
        guard let rootIndex = Note.sharpNames.firstIndex(of: root) else { return [] }
        let scaleDef = standardScales.first { $0.id == scaleId } ?? standardScales[0]
        let intervals = scaleDef.intervals
        let baseMidi = (octave + 1) * 12 + rootIndex

        var notes: [Note] = []
        for i in 0..<count {
            let octaveOffset = (i / intervals.count) * 12
            let interval = intervals[i % intervals.count]
            notes.append(Note(midi: baseMidi + octaveOffset + interval))
        }
        return notes
    }
}
