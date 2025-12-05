import AVFoundation

class TTSManager: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    @Published var isEnabled = true
    
    func speak(_ text: String, completion: (() -> Void)? = nil) {
        guard isEnabled, !text.isEmpty else {
            completion?()
            return
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.5 // 少しゆっくり
        utterance.volume = 0.8
        
        isSpeaking = true
        
        // 完了時のコールバック
        if let completion = completion {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(text.count) * 0.1) {
                self.isSpeaking = false
                completion()
            }
        }
        
        synthesizer.speak(utterance)
    }
    
    func speakTelemetry(_ telemetry: TelemetryData, completion: (() -> Void)? = nil) {
        let description = telemetry.description
        speak(description, completion: completion)
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
}
