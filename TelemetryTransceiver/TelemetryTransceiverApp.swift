import SwiftUI
import AVFoundation

@main
struct TelemetryTransceiverApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    requestPermissions()
                }
        }
    }
    
    private func requestPermissions() {
        // マイク権限
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            print("Microphone permission: \(granted)")
        }
    }
}
