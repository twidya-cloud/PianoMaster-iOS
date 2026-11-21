# 🎹 PianoMaster - Native iOS iPhone Piano Learning App

A full-featured native iOS piano learning app engineered in **Swift 5.9+** and **SwiftUI**, built specifically for iPhone and iPad.

---

## 📱 Features

1. **🎵 Synthesia-Style Falling Notes Game (`FallingNotesView`)**
   - High performance 60/120 FPS SwiftUI Canvas visualizer.
   - **Wait For Me (Practice Mode)**: Halts note flow at the hit line until you play the correct key.
   - **Flow (Play Along)**: Real-time hit detection (`PERFECT! +100`, `GOOD! +50`, `MISS`), combo multiplier, and score streak.
   - **Demo Mode**: Autoplays the piece with synchronized audio and illuminated key presses.
   - Speed adjustment slider (0.5x to 1.5x) and Left/Right hand isolation.

2. **🎼 Built-In Song Library (`SongLibrary`)**
   - *Twinkle Twinkle Little Star* (Beginner)
   - *Ode to Joy* – Beethoven (Beginner)
   - *Für Elise* – Beethoven (Intermediate)
   - *Canon in D* – Pachelbel (Intermediate)
   - *Happy Birthday to You* (Beginner)

3. **🎹 Low-Latency Physical Modeling Audio Engine (`PianoAudioEngine`)**
   - Native `AVAudioEngine` and `AVAudioSourceNode` with additive harmonic synthesis and dynamic ADSR envelopes.
   - `AVAudioUnitReverb` simulating medium hall concert acoustics.
   - Sustain pedal emulation (hold pedal button to let strings ring out naturally).

4. **🎛️ Real-Time Chord Detection (`ChordHUDView`)**
   - Automatically identifies triads, 7th chords, suspensions, and inversions as you play.

5. **📚 Chords & Scales Academy (`ChordsScalesView`)**
   - Interactive chord and scale explorer with interval formulas, visual key highlights, and arpeggio playback.

6. **𝄞 Sight Reading Flashcards (`SightReadingView`)**
   - Custom SwiftUI `Canvas` grand staff (Treble and Bass clefs, ledger lines, accidentals) for sight reading practice.

7. **👂 Pitch Memory & Ear Trainer (`EarTrainingView`)**
   - Mystery note audio guessing game to develop perfect and relative pitch.

8. **⏺ Performance Recorder & Studio (`StudioView`)**
   - Record keystrokes, save performances locally to `UserDefaults`, and play back anytime.

9. **🔌 Hardware CoreMIDI Support (`MIDIManager`)**
   - Automatically detects and connects to USB-C, Lightning, or Bluetooth MIDI keyboards.

---

## 🛠️ Project Structure

```
PianoMaster-iOS/
├── PianoMaster.xcodeproj/     # Standard Xcode project
├── Package.swift               # Swift Package definition
├── README.md
└── PianoMaster/
    ├── PianoMasterApp.swift    # App entry point (@main)
    ├── Info.plist              # Bundle config, orientations, background audio
    ├── Models/
    │   ├── Note.swift          # Note struct, frequencies, names, solfege
    │   ├── Chord.swift         # Chord recognition & intervals
    │   ├── Scale.swift         # Scales, modes, definitions
    │   ├── Song.swift          # Song models & library
    │   └── Recording.swift     # Performance recording models
    ├── Audio/
    │   └── PianoAudioEngine.swift # Low-latency AVAudioEngine synthesis
    ├── MIDI/
    │   └── MIDIManager.swift   # CoreMIDI hardware client
    └── Views/
        ├── ContentView.swift   # Main navigation & root shell
        ├── Piano/
        │   ├── PianoKeyView.swift        # Realistic 3D key component
        │   ├── PianoKeyboardView.swift   # Multi-touch virtual keyboard
        │   └── ChordHUDView.swift        # Real-time chord banner
        ├── FallingNotes/
        │   └── FallingNotesView.swift    # 60/120 FPS game canvas
        └── Academy/
            ├── ChordsScalesView.swift    # Chord & scale explorer
            ├── SightReadingView.swift    # Sheet music staff trainer
            ├── EarTrainingView.swift     # Ear training pitch quiz
            └── StudioView.swift          # Performance recorder
```

---

## 🚀 How to Run on iPhone / Simulator

1. **Open the Project in Xcode**:
   Double-click `PianoMaster.xcodeproj` or run:
   ```bash
   open /Users/tomy/PianoMaster-iOS/PianoMaster.xcodeproj
   ```
   *(Or open `Package.swift` directly in Xcode)*.

2. **Select Target Device**:
   In Xcode's top toolbar, select any iPhone simulator (e.g., **iPhone 15 / 16 Pro**) or your connected physical iPhone.

3. **Run (`⌘R`)**:
   Press **Command + R** to build and run. The app is optimized for landscape orientation for an expansive piano key view!
