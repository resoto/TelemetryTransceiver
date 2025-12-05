import Foundation

enum PacketType: String, Codable {
    case audio
    case telemetry
    case beep
}

struct DataPacket: Codable {
    let type: PacketType
    let senderID: String
    let timestamp: Date
    let data: Data
    
    init(type: PacketType, senderID: String, data: Data) {
        self.type = type
        self.senderID = senderID
        self.timestamp = Date()
        self.data = data
    }
    
    func encode() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
    static func decode(from data: Data) -> DataPacket? {
        return try? JSONDecoder().decode(DataPacket.self, from: data)
    }
}
