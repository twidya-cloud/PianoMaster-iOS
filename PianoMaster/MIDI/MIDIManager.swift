import Foundation
import CoreMIDI

public final class MIDIManager: ObservableObject {
    @Published public var connectedDevices: [String] = []
    @Published public var isMidiConnected: Bool = false
    
    public var onNoteOn: ((Int, Float) -> Void)?
    public var onNoteOff: ((Int) -> Void)?
    public var onPedalChange: ((Bool) -> Void)?

    private var midiClient = MIDIClientRef()
    private var inputPort = MIDIPortRef()

    public init() {
        setupMidi()
    }

    private func setupMidi() {
        var status = MIDIClientCreateWithBlock("PianoMasterMIDIClient" as CFString, &midiClient) { [weak self] notify in
            DispatchQueue.main.async {
                self?.refreshDevices()
            }
        }
        guard status == noErr else { return }

        status = MIDIInputPortCreateWithBlock(midiClient, "PianoMasterInputPort" as CFString, &inputPort) { [weak self] packetList, _ in
            self?.handleMidiPackets(packetList)
        }
        guard status == noErr else { return }

        refreshDevices()
    }

    public func refreshDevices() {
        let sourceCount = MIDIGetNumberOfSources()
        var names: [String] = []

        for i in 0..<sourceCount {
            let src = MIDIGetSource(i)
            MIDIPortConnectSource(inputPort, src, nil)

            var name: Unmanaged<CFString>?
            MIDIObjectGetStringProperty(src, kMIDIPropertyName, &name)
            if let cfStr = name?.takeRetainedValue() {
                names.append(cfStr as String)
            } else {
                names.append("MIDI Keyboard \(i + 1)")
            }
        }

        self.connectedDevices = names
        self.isMidiConnected = !names.isEmpty
    }

    private func handleMidiPackets(_ packetListPtr: UnsafePointer<MIDIPacketList>) {
        let packetList = packetListPtr.pointee
        var packet = packetList.packet

        for _ in 0..<packetList.numPackets {
            let length = packet.length
            guard length >= 2 else { continue }

            withUnsafeBytes(of: &packet.data) { rawBytes in
                let bytes = rawBytes.bindMemory(to: UInt8.self)
                let status = bytes[0]
                let cmd = status >> 4
                let note = Int(bytes[1])
                let velocity = length > 2 ? Float(bytes[2]) / 127.0 : 0.0

                DispatchQueue.main.async { [weak self] in
                    // Note On (cmd 9)
                    if cmd == 9 {
                        if velocity > 0 {
                            self?.onNoteOn?(note, velocity)
                        } else {
                            self?.onNoteOff?(note)
                        }
                    }
                    // Note Off (cmd 8)
                    else if cmd == 8 {
                        self?.onNoteOff?(note)
                    }
                    // Control Change (cmd 11) - Sustain Pedal CC 64
                    else if cmd == 11 && length > 2 {
                        let ccNumber = bytes[1]
                        let ccVal = bytes[2]
                        if ccNumber == 64 {
                            self?.onPedalChange?(ccVal >= 64)
                        }
                    }
                }
            }

            packet = MIDIPacketNext(&packet).pointee
        }
    }
}
