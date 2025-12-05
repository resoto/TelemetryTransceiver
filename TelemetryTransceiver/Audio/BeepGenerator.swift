import AVFoundation

class BeepGenerator: ObservableObject {
    private let audioEngine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    @Published var isEnabled = true
    
    init() {
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        // Temporarily disabled to isolate crash
        /*
        audioEngine.attach(playerNode)
        
        // Use a standard format that's guaranteed to work
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)
        
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start beep audio engine: \(error)")
        }
        */
    }
    
    func playBeep(for type: BeepType) {
        guard isEnabled else { return }
        
        switch type {
        case .normal:
            playTone(frequency: 1000, duration: 0.1, count: 1)
        case .stationary:
            playTone(frequency: 400, duration: 0.3, count: 1)
        case .batteryWarning:
            playTone(frequency: 1000, duration: 0.1, count: 3, interval: 0.1)
        case .emergency:
            playTone(frequency: 1500, duration: 0.5, count: 3, interval: 0.2)
        }
    }
    
    private func playTone(frequency: Float, duration: TimeInterval, count: Int, interval: TimeInterval = 0) {
        let sampleRate: Double = 44100
        let amplitude: Float = 0.3
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        for i in 0..<count {
            let delay = Double(i) * (duration + interval)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self else { return }
                
                let frameCount = AVAudioFrameCount(sampleRate * duration)
                guard let buffer = AVAudioPCMBuffer(
                    pcmFormat: format,
                    frameCapacity: frameCount
                ) else { return }
                
                buffer.frameLength = frameCount
                
                guard let channelData = buffer.floatChannelData?[0] else { return }
                
                for frame in 0..<Int(frameCount) {
                    let value = sin(2.0 * .pi * Float(frame) * frequency / Float(sampleRate))
                    channelData[frame] = value * amplitude
                }
                
                self.playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
                
                if !self.playerNode.isPlaying {
                    self.playerNode.play()
                }
            }
        }
    }
}
