import SwiftUI

struct ContentView: View {
    @StateObject private var networkManager = NetworkManager()
    @StateObject private var telemetryManager = TelemetryManager()
    @StateObject private var audioEngine = AudioEngine()
    
    var body: some View {
        TransceiverView()
            .environmentObject(networkManager)
            .environmentObject(telemetryManager)
            .environmentObject(audioEngine)
            .onAppear {
                // 権限をリクエスト
                telemetryManager.requestLocationPermission()
            }
    }
}

#Preview {
    ContentView()
}
