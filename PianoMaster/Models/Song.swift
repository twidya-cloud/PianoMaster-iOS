import Foundation

public enum HandType: String, Codable, CaseIterable {
    case right = "right"
    case left = "left"
    case both = "both"

    public var title: String {
        switch self {
        case .right: return "Right Hand (Melody)"
        case .left: return "Left Hand (Bass)"
        case .both: return "Both Hands"
        }
    }
}

public struct SongNote: Identifiable, Codable {
    public var id = UUID()
    public let midi: Int
    public let time: Double      // seconds from song start
    public let duration: Double  // seconds held
    public let hand: HandType

    public init(midi: Int, time: Double, duration: Double, hand: HandType = .right) {
        self.midi = midi
        self.time = time
        self.duration = duration
        self.hand = hand
    }
}

public struct Song: Identifiable {
    public let id: String
    public let title: String
    public let composer: String
    public let difficulty: String
    public let tempo: Int
    public let key: String
    public let description: String
    public let notes: [SongNote]

    public var duration: Double {
        guard let last = notes.max(by: { ($0.time + $0.duration) < ($1.time + $1.duration) }) else { return 0 }
        return last.time + last.duration
    }
}

public struct SongLibrary {
    public static let songs: [Song] = [
        Song(
            id: "twinkle",
            title: "Twinkle Twinkle Little Star",
            composer: "Traditional",
            difficulty: "Beginner",
            tempo: 90,
            key: "C Major",
            description: "Perfect for beginners. Simple repetitive melodic intervals in C Major.",
            notes: [
                // C C G G A A G
                SongNote(midi: 60, time: 0.0, duration: 0.5, hand: .right),
                SongNote(midi: 48, time: 0.0, duration: 1.0, hand: .left),
                SongNote(midi: 60, time: 0.6, duration: 0.5, hand: .right),
                SongNote(midi: 67, time: 1.2, duration: 0.5, hand: .right),
                SongNote(midi: 55, time: 1.2, duration: 1.0, hand: .left),
                SongNote(midi: 67, time: 1.8, duration: 0.5, hand: .right),
                SongNote(midi: 69, time: 2.4, duration: 0.5, hand: .right),
                SongNote(midi: 57, time: 2.4, duration: 1.0, hand: .left),
                SongNote(midi: 69, time: 3.0, duration: 0.5, hand: .right),
                SongNote(midi: 67, time: 3.6, duration: 1.0, hand: .right),
                SongNote(midi: 55, time: 3.6, duration: 1.0, hand: .left),

                // F F E E D D C
                SongNote(midi: 65, time: 4.8, duration: 0.5, hand: .right),
                SongNote(midi: 53, time: 4.8, duration: 1.0, hand: .left),
                SongNote(midi: 65, time: 5.4, duration: 0.5, hand: .right),
                SongNote(midi: 64, time: 6.0, duration: 0.5, hand: .right),
                SongNote(midi: 52, time: 6.0, duration: 1.0, hand: .left),
                SongNote(midi: 64, time: 6.6, duration: 0.5, hand: .right),
                SongNote(midi: 62, time: 7.2, duration: 0.5, hand: .right),
                SongNote(midi: 50, time: 7.2, duration: 1.0, hand: .left),
                SongNote(midi: 62, time: 7.8, duration: 0.5, hand: .right),
                SongNote(midi: 60, time: 8.4, duration: 1.2, hand: .right),
                SongNote(midi: 48, time: 8.4, duration: 1.2, hand: .left),

                // G G F F E E D
                SongNote(midi: 67, time: 10.0, duration: 0.5, hand: .right),
                SongNote(midi: 55, time: 10.0, duration: 1.0, hand: .left),
                SongNote(midi: 67, time: 10.6, duration: 0.5, hand: .right),
                SongNote(midi: 65, time: 11.2, duration: 0.5, hand: .right),
                SongNote(midi: 53, time: 11.2, duration: 1.0, hand: .left),
                SongNote(midi: 65, time: 11.8, duration: 0.5, hand: .right),
                SongNote(midi: 64, time: 12.4, duration: 0.5, hand: .right),
                SongNote(midi: 52, time: 12.4, duration: 1.0, hand: .left),
                SongNote(midi: 64, time: 13.0, duration: 0.5, hand: .right),
                SongNote(midi: 62, time: 13.6, duration: 1.0, hand: .right),
                SongNote(midi: 50, time: 13.6, duration: 1.0, hand: .left)
            ]
        ),
        Song(
            id: "ode_to_joy",
            title: "Ode to Joy",
            composer: "Ludwig van Beethoven",
            difficulty: "Beginner",
            tempo: 110,
            key: "C Major",
            description: "Triumphant anthem from Symphony No. 9. Great for fundamental finger agility.",
            notes: [
                SongNote(midi: 64, time: 0.0, duration: 0.45, hand: .right),
                SongNote(midi: 48, time: 0.0, duration: 1.0, hand: .left),
                SongNote(midi: 64, time: 0.55, duration: 0.45, hand: .right),
                SongNote(midi: 65, time: 1.1, duration: 0.45, hand: .right),
                SongNote(midi: 67, time: 1.65, duration: 0.45, hand: .right),
                SongNote(midi: 55, time: 1.65, duration: 1.0, hand: .left),

                SongNote(midi: 67, time: 2.2, duration: 0.45, hand: .right),
                SongNote(midi: 65, time: 2.75, duration: 0.45, hand: .right),
                SongNote(midi: 64, time: 3.3, duration: 0.45, hand: .right),
                SongNote(midi: 48, time: 3.3, duration: 1.0, hand: .left),
                SongNote(midi: 62, time: 3.85, duration: 0.45, hand: .right),

                SongNote(midi: 60, time: 4.4, duration: 0.45, hand: .right),
                SongNote(midi: 60, time: 4.95, duration: 0.45, hand: .right),
                SongNote(midi: 53, time: 4.95, duration: 1.0, hand: .left),
                SongNote(midi: 62, time: 5.5, duration: 0.45, hand: .right),
                SongNote(midi: 64, time: 6.05, duration: 0.45, hand: .right),
                SongNote(midi: 48, time: 6.05, duration: 1.0, hand: .left),

                SongNote(midi: 64, time: 6.6, duration: 0.6, hand: .right),
                SongNote(midi: 62, time: 7.3, duration: 0.25, hand: .right),
                SongNote(midi: 55, time: 7.3, duration: 1.0, hand: .left),
                SongNote(midi: 62, time: 7.7, duration: 0.8, hand: .right)
            ]
        ),
        Song(
            id: "fur_elise",
            title: "Für Elise",
            composer: "Ludwig van Beethoven",
            difficulty: "Intermediate",
            tempo: 125,
            key: "A Minor",
            description: "The world's most beloved piano composition. Teaches chromatic oscillations and broken chords.",
            notes: [
                SongNote(midi: 76, time: 0.0, duration: 0.28, hand: .right),
                SongNote(midi: 75, time: 0.32, duration: 0.28, hand: .right),
                SongNote(midi: 76, time: 0.64, duration: 0.28, hand: .right),
                SongNote(midi: 75, time: 0.96, duration: 0.28, hand: .right),
                SongNote(midi: 76, time: 1.28, duration: 0.28, hand: .right),
                SongNote(midi: 71, time: 1.60, duration: 0.28, hand: .right),
                SongNote(midi: 74, time: 1.92, duration: 0.28, hand: .right),
                SongNote(midi: 72, time: 2.24, duration: 0.28, hand: .right),
                SongNote(midi: 69, time: 2.56, duration: 0.75, hand: .right),
                SongNote(midi: 45, time: 2.56, duration: 0.4, hand: .left),
                SongNote(midi: 52, time: 2.90, duration: 0.4, hand: .left),
                SongNote(midi: 57, time: 3.24, duration: 0.4, hand: .left),

                SongNote(midi: 60, time: 3.58, duration: 0.28, hand: .right),
                SongNote(midi: 64, time: 3.90, duration: 0.28, hand: .right),
                SongNote(midi: 69, time: 4.22, duration: 0.28, hand: .right),
                SongNote(midi: 71, time: 4.54, duration: 0.75, hand: .right),
                SongNote(midi: 40, time: 4.54, duration: 0.4, hand: .left),
                SongNote(midi: 52, time: 4.88, duration: 0.4, hand: .left),
                SongNote(midi: 56, time: 5.22, duration: 0.4, hand: .left),

                SongNote(midi: 64, time: 5.56, duration: 0.28, hand: .right),
                SongNote(midi: 68, time: 5.88, duration: 0.28, hand: .right),
                SongNote(midi: 71, time: 6.20, duration: 0.28, hand: .right),
                SongNote(midi: 72, time: 6.52, duration: 0.75, hand: .right),
                SongNote(midi: 45, time: 6.52, duration: 0.4, hand: .left),
                SongNote(midi: 52, time: 6.86, duration: 0.4, hand: .left),
                SongNote(midi: 57, time: 7.20, duration: 0.4, hand: .left)
            ]
        ),
        Song(
            id: "canon_in_d",
            title: "Canon in D",
            composer: "Johann Pachelbel",
            difficulty: "Intermediate",
            tempo: 80,
            key: "D Major",
            description: "Calming Baroque classic based on the world's most famous harmonic progression.",
            notes: [
                SongNote(midi: 74, time: 0.0, duration: 1.0, hand: .right),
                SongNote(midi: 50, time: 0.0, duration: 1.5, hand: .left),
                SongNote(midi: 73, time: 1.5, duration: 1.0, hand: .right),
                SongNote(midi: 45, time: 1.5, duration: 1.5, hand: .left),
                SongNote(midi: 71, time: 3.0, duration: 1.0, hand: .right),
                SongNote(midi: 47, time: 3.0, duration: 1.5, hand: .left),
                SongNote(midi: 69, time: 4.5, duration: 1.0, hand: .right),
                SongNote(midi: 42, time: 4.5, duration: 1.5, hand: .left),
                SongNote(midi: 67, time: 6.0, duration: 1.0, hand: .right),
                SongNote(midi: 43, time: 6.0, duration: 1.5, hand: .left),
                SongNote(midi: 66, time: 7.5, duration: 1.0, hand: .right),
                SongNote(midi: 50, time: 7.5, duration: 1.5, hand: .left),
                SongNote(midi: 67, time: 9.0, duration: 1.0, hand: .right),
                SongNote(midi: 43, time: 9.0, duration: 1.5, hand: .left),
                SongNote(midi: 69, time: 10.5, duration: 1.2, hand: .right),
                SongNote(midi: 45, time: 10.5, duration: 1.5, hand: .left)
            ]
        ),
        Song(
            id: "happy_birthday",
            title: "Happy Birthday to You",
            composer: "Traditional",
            difficulty: "Beginner",
            tempo: 100,
            key: "F Major",
            description: "Celebratory sing-along favorite. Great for practicing dotted rhythms and octave leaps.",
            notes: [
                SongNote(midi: 60, time: 0.0, duration: 0.35, hand: .right),
                SongNote(midi: 60, time: 0.4, duration: 0.25, hand: .right),
                SongNote(midi: 62, time: 0.7, duration: 0.6, hand: .right),
                SongNote(midi: 53, time: 0.7, duration: 1.2, hand: .left),
                SongNote(midi: 60, time: 1.4, duration: 0.6, hand: .right),
                SongNote(midi: 65, time: 2.1, duration: 0.6, hand: .right),
                SongNote(midi: 53, time: 2.1, duration: 1.2, hand: .left),
                SongNote(midi: 64, time: 2.8, duration: 1.1, hand: .right),

                SongNote(midi: 60, time: 4.2, duration: 0.35, hand: .right),
                SongNote(midi: 60, time: 4.6, duration: 0.25, hand: .right),
                SongNote(midi: 62, time: 4.9, duration: 0.6, hand: .right),
                SongNote(midi: 55, time: 4.9, duration: 1.2, hand: .left),
                SongNote(midi: 60, time: 5.6, duration: 0.6, hand: .right),
                SongNote(midi: 67, time: 6.3, duration: 0.6, hand: .right),
                SongNote(midi: 55, time: 6.3, duration: 1.2, hand: .left),
                SongNote(midi: 65, time: 7.0, duration: 1.1, hand: .right)
            ]
        )
    ]
}
