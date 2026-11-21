import SwiftUI

public struct StudioView: View {
    @ObservedObject var audioEngine: PianoAudioEngine
    @Binding var isRecording: Bool
    @Binding var recordedEvents: [RecordedEvent]
    
    @State private var recordings: [PerformanceRecording] = []
    @State private var recordStartTime: Date = Date()
    @State private var showSaveAlert: Bool = false
    @State private var recordingTitleInput: String = ""

    private let storageKey = "piano_master_saved_recordings"

    public init(audioEngine: PianoAudioEngine, isRecording: Binding<Bool>, recordedEvents: Binding<[RecordedEvent]>) {
        self.audioEngine = audioEngine
        self._isRecording = isRecording
        self._recordedEvents = recordedEvents
    }

    public var body: some View {
        VStack(spacing: 14) {
            // Header & Record Button
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("⏺ Performance Recorder")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text("Capture your piano performances and listen back.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: toggleRecording) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                        Text(isRecording ? "Stop Recording" : "Record")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(isRecording ? Color.red.opacity(0.8) : Color(white: 0.2))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }

            // Saved Recordings List
            VStack(alignment: .leading, spacing: 8) {
                Text("Saved Performances (\(recordings.count))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.secondary)

                if recordings.isEmpty {
                    Text("No recordings saved yet. Tap 'Record' to create one!")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(recordings) { rec in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(rec.title)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text("\(rec.noteCount) notes • \(String(format: "%.1fs", rec.duration))")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Button(action: { playRecording(rec) }) {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.cyan)
                                    }

                                    Button(action: { deleteRecording(rec) }) {
                                        Image(systemName: "trash")
                                            .font(.system(size: 16))
                                            .foregroundColor(.red.opacity(0.8))
                                    }
                                }
                                .padding(10)
                                .background(Color(white: 0.12))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .frame(maxHeight: 180)
                }
            }
        }
        .padding()
        .background(Color(white: 0.08))
        .cornerRadius(14)
        .onAppear(perform: loadRecordings)
        .alert("Save Performance", isPresented: $showSaveAlert) {
            TextField("Song Name", text: $recordingTitleInput)
            Button("Save", action: saveRecording)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter a title for your recorded piano piece.")
        }
    }

    private func toggleRecording() {
        if !isRecording {
            isRecording = true
            recordedEvents.removeAll()
            recordStartTime = Date()
        } else {
            isRecording = false
            if !recordedEvents.isEmpty {
                recordingTitleInput = "My Song \(Date().formatted(date: .omitted, time: .shortened))"
                showSaveAlert = true
            }
        }
    }

    private func saveRecording() {
        let title = recordingTitleInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Untitled Performance"
            : recordingTitleInput

        let newRec = PerformanceRecording(title: title, events: recordedEvents)
        recordings.insert(newRec, at: 0)
        persistRecordings()
    }

    private func deleteRecording(_ rec: PerformanceRecording) {
        recordings.removeAll(where: { $0.id == rec.id })
        persistRecordings()
    }

    private func persistRecordings() {
        if let data = try? JSONEncoder().encode(recordings) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadRecordings() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let list = try? JSONDecoder().decode([PerformanceRecording].self, from: data) {
            self.recordings = list
        }
    }

    private func playRecording(_ rec: PerformanceRecording) {
        for evt in rec.events {
            DispatchQueue.main.asyncAfter(deadline: .now() + evt.time) {
                if evt.type == "noteOn" {
                    audioEngine.playNote(midi: evt.midi, velocity: evt.velocity)
                } else {
                    audioEngine.stopNote(midi: evt.midi)
                }
            }
        }
    }
}
