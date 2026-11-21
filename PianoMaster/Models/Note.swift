import Foundation

/// Represents a musical pitch and MIDI note number
public struct Note: Identifiable, Hashable, Codable {
    public let midi: Int

    public var id: Int { midi }

    public init(midi: Int) {
        self.midi = max(21, min(108, midi)) // Standard 88-key range: A0 to C8
    }

    public init(name: String) {
        // e.g. "C4", "F#5", "Bb3"
        let pattern = "^([A-Ga-g][#b]?)(-?\\d+)$"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: name, range: NSRange(name.startIndex..., in: name)) {
            let noteStr = (name as NSString).substring(with: match.range(at: 1)).capitalized
            let octaveStr = (name as NSString).substring(with: match.range(at: 2))
            let octave = Int(octaveStr) ?? 4

            let namesSharp = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
            let namesFlat = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]

            var pc = namesSharp.firstIndex(of: noteStr)
            if pc == nil {
                pc = namesFlat.firstIndex(of: noteStr)
            }
            if let pc = pc {
                self.midi = (octave + 1) * 12 + pc
                return
            }
        }
        self.midi = 60 // Default Middle C
    }

    public static let sharpNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    public static let flatNames  = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"]
    public static let solfege    = ["Do", "Do#", "Re", "Re#", "Mi", "Fa", "Fa#", "Sol", "Sol#", "La", "La#", "Si"]

    /// Pitch class (0 to 11, where 0 = C)
    public var pitchClass: Int {
        return midi % 12
    }

    /// Octave number (-1 to 9, where C4 = 4)
    public var octave: Int {
        return (midi / 12) - 1
    }

    /// Note letter name with octave, e.g. "C4", "A4"
    public var name: String {
        return "\(Note.sharpNames[pitchClass])\(octave)"
    }

    /// Just the base note name, e.g. "C", "F#"
    public var baseName: String {
        return Note.sharpNames[pitchClass]
    }

    /// Solfège name, e.g. "Do", "Sol"
    public var solfegeName: String {
        return Note.solfege[pitchClass]
    }

    /// Whether this is an accidental black key
    public var isBlackKey: Bool {
        let pc = pitchClass
        return pc == 1 || pc == 3 || pc == 6 || pc == 8 || pc == 10
    }

    /// Frequency in Hertz (A4 = 440 Hz)
    public var frequency: Float {
        return 440.0 * pow(2.0, Float(midi - 69) / 12.0)
    }

    /// Diatonic staff step for sheet music notation (C=0, D=1, E=2, F=3, G=4, A=5, B=6)
    public var staffStep: Int {
        let diatonic = [0, 0, 1, 1, 2, 3, 3, 4, 4, 5, 5, 6]
        return octave * 7 + diatonic[pitchClass]
    }

    public static let middleC = Note(midi: 60)
}
