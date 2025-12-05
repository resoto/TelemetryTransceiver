import SwiftUI

struct TelemetryDisplayView: View {
    let telemetry: TelemetryData
    
    var body: some View {
        VStack(spacing: 15) {
            Text("相手の状態")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                // 標高
                if let altitude = telemetry.altitude {
                    TelemetryItem(
                        icon: "mountain.2.fill",
                        label: "標高",
                        value: "\(Int(altitude))m",
                        color: .green
                    )
                }
                
                // バッテリー
                TelemetryItem(
                    icon: batteryIcon,
                    label: "バッテリー",
                    value: "\(Int(telemetry.batteryLevel * 100))%",
                    color: batteryColor
                )
                
                // 動き
                TelemetryItem(
                    icon: telemetry.isMoving ? "figure.walk" : "figure.stand",
                    label: "状態",
                    value: telemetry.isMoving ? "移動中" : "停滞",
                    color: telemetry.isMoving ? .blue : .orange
                )
            }
            
            // デバイス名
            Text(telemetry.deviceName)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
    }
    
    private var batteryIcon: String {
        let level = telemetry.batteryLevel
        if level > 0.75 {
            return "battery.100"
        } else if level > 0.5 {
            return "battery.75"
        } else if level > 0.25 {
            return "battery.25"
        } else {
            return "battery.0"
        }
    }
    
    private var batteryColor: Color {
        telemetry.batteryLevel < 0.2 ? .red : .green
    }
}

struct TelemetryItem: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}
