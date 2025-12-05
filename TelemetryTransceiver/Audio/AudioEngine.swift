import AVFoundation
import Combine

class AudioEngine: ObservableObject {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?
    
    @Published var isRecording = false
    @Published var isPlaying = false
    
    private var recordingFile: AVAudioFile?
    private var recordingBuffer: AVAudioPCMBuffer?
    
    var onAudioDataRecorded: ((Data) -> Void)?
    var onPlaybackFinished: (() -> Void)?
    
    init() {
        setupAudioSession()
        setupAudioEngine()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .voiceChat, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
            // Don't crash, just log the error
        }
    }
    
    private func setupAudioEngine() {
        // Temporarily disabled to isolate crash
        /*
        engine.attach(playerNode)
        
        // Use a safe format that doesn't require input node access
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)
        if let format = format {
            engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        }
        
        do {
            try engine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
            // Don't crash, engine will start later when needed
        }
        */
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        // 録音データを保存するバッファ
        var recordedBuffers: [AVAudioPCMBuffer] = []
        
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: format) { buffer, time in
            // バッファをコピーして保存
            if let copy = self.copyBuffer(buffer) {
                recordedBuffers.append(copy)
            }
        }
        
        isRecording = true
        
        // 録音終了時の処理を保存
        DispatchQueue.main.async {
            self.recordingBuffer = self.mergeBuffers(recordedBuffers, format: format)
        }
    }
    
    func stopRecording() -> Data? {
        guard isRecording else { return nil }
        
        engine.inputNode.removeTap(onBus: 0)
        isRecording = false
        
        // バッファをDataに変換
        guard let buffer = recordingBuffer else { return nil }
        return convertBufferToData(buffer)
    }
    
    func playAudio(data: Data) {
        guard let buffer = convertDataToBuffer(data) else {
            print("Failed to convert data to buffer")
            return
        }
        
        playerNode.scheduleBuffer(buffer) { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
                self?.onPlaybackFinished?()
            }
        }
        
        if !playerNode.isPlaying {
            playerNode.play()
        }
        
        isPlaying = true
    }
    
    // MARK: - Helper Methods
    
    private func copyBuffer(_ buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer? {
        guard let copy = AVAudioPCMBuffer(
            pcmFormat: buffer.format,
            frameCapacity: buffer.frameCapacity
        ) else { return nil }
        
        copy.frameLength = buffer.frameLength
        
        for channel in 0..<Int(buffer.format.channelCount) {
            if let src = buffer.floatChannelData?[channel],
               let dst = copy.floatChannelData?[channel] {
                dst.assign(from: src, count: Int(buffer.frameLength))
            }
        }
        
        return copy
    }
    
    private func mergeBuffers(_ buffers: [AVAudioPCMBuffer], format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let totalFrames = buffers.reduce(0) { $0 + $1.frameLength }
        
        guard let mergedBuffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(totalFrames)
        ) else { return nil }
        
        var currentFrame: AVAudioFrameCount = 0
        
        for buffer in buffers {
            for channel in 0..<Int(format.channelCount) {
                if let src = buffer.floatChannelData?[channel],
                   let dst = mergedBuffer.floatChannelData?[channel] {
                    let dstPointer = dst.advanced(by: Int(currentFrame))
                    dstPointer.assign(from: src, count: Int(buffer.frameLength))
                }
            }
            currentFrame += buffer.frameLength
        }
        
        mergedBuffer.frameLength = AVAudioFrameCount(totalFrames)
        return mergedBuffer
    }
    
    private func convertBufferToData(_ buffer: AVAudioPCMBuffer) -> Data? {
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        return Data(bytes: audioBuffer.mData!, count: Int(audioBuffer.mDataByteSize))
    }
    
    private func convertDataToBuffer(_ data: Data) -> AVAudioPCMBuffer? {
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        let frameCount = UInt32(data.count) / format.streamDescription.pointee.mBytesPerFrame
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            return nil
        }
        
        buffer.frameLength = frameCount
        
        let audioBuffer = buffer.audioBufferList.pointee.mBuffers
        data.copyBytes(to: UnsafeMutableBufferPointer(
            start: audioBuffer.mData?.assumingMemoryBound(to: UInt8.self),
            count: Int(audioBuffer.mDataByteSize)
        ))
        
        return buffer
    }
}
