import AVFoundation

class AudioMixer: ObservableObject {
    private let engine = AVAudioEngine()
    private let voicePlayerNode = AVAudioPlayerNode()
    private let ttsPlayerNode = AVAudioPlayerNode()
    private let mixerNode = AVAudioMixerNode()
    
    init() {
        setupMixer()
    }
    
    private func setupMixer() {
        // Temporarily disabled to isolate crash
        /*
        engine.attach(voicePlayerNode)
        engine.attach(ttsPlayerNode)
        engine.attach(mixerNode)
        
        // Use a standard format
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        
        // 音声ノードをミキサーに接続
        engine.connect(voicePlayerNode, to: mixerNode, format: format)
        engine.connect(ttsPlayerNode, to: mixerNode, format: format)
        
        // ミキサーをメインミキサーに接続
        engine.connect(mixerNode, to: engine.mainMixerNode, format: format)
        
        // 音量バランスの設定
        voicePlayerNode.volume = 1.0  // 相手の音声は通常音量
        ttsPlayerNode.volume = 0.7    // TTSは少し小さめ
        
        do {
            try engine.start()
        } catch {
            print("Failed to start mixer engine: \(error)")
        }
        */
    }
    
    func playVoice(_ buffer: AVAudioPCMBuffer, completion: (() -> Void)? = nil) {
        voicePlayerNode.scheduleBuffer(buffer) {
            completion?()
        }
        
        if !voicePlayerNode.isPlaying {
            voicePlayerNode.play()
        }
    }
    
    func playTTS(_ buffer: AVAudioPCMBuffer, completion: (() -> Void)? = nil) {
        ttsPlayerNode.scheduleBuffer(buffer) {
            completion?()
        }
        
        if !ttsPlayerNode.isPlaying {
            ttsPlayerNode.play()
        }
    }
    
    func setVoiceVolume(_ volume: Float) {
        voicePlayerNode.volume = volume
    }
    
    func setTTSVolume(_ volume: Float) {
        ttsPlayerNode.volume = volume
    }
}
