import Foundation

public struct RecordedEvent: Codable, Identifiable {
    public var id = UUID()
    public let type: String // "noteOn" or "noteOff"
    public let midi: Int
    public let time: Double
    public let velocity: Float
}

public struct PerformanceRecording: Codable, Identifiable {
    public let id: String
    public let title: String
    public let date: Date
    public let events: [RecordedEvent]

    public var noteCount: Int {
        events.filter { $0.type == "noteOn" }.count
    }

    public var duration: Double {
        events.last?.time ?? 0.0
    }

    public init(id: String = UUID().uuidString, title: String, date: Date = Date(), events: [RecordedEvent]) {
        self.id = id
        self.title = title
        self.date = date
        self.events = events
    }
}
