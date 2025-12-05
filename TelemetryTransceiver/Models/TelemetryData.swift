import Foundation

struct TelemetryData: Codable {
    let timestamp: Date
    let altitude: Double?
    let latitude: Double?
    let longitude: Double?
    let batteryLevel: Float
    let isMoving: Bool
    let deviceName: String
    
    var description: String {
        var parts: [String] = []
        
        if let altitude = altitude {
            parts.append("標高\(Int(altitude))メートル")
        }
        
        let batteryPercent = Int(batteryLevel * 100)
        if batteryLevel < 0.2 {
            parts.append("バッテリー低下、残り\(batteryPercent)パーセント")
        } else if batteryLevel < 0.5 {
            parts.append("バッテリー\(batteryPercent)パーセント")
        }
        
        if !isMoving {
            parts.append("停滞中")
        }
        
        return parts.joined(separator: "、")
    }
    
    var beepType: BeepType {
        // バッテリー警告が最優先
        if batteryLevel < 0.15 {
            return .batteryWarning
        }
        
        // 停滞中
        if !isMoving {
            return .stationary
        }
        
        // 通常
        return .normal
    }
}

enum BeepType {
    case normal        // 高音の「ピッ」
    case stationary    // 低音の「プゥ」
    case batteryWarning // 「ピピピッ」
    case emergency     // 「ピーピーピー」
}
