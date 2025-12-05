import SwiftUI
import MultipeerConnectivity

struct TransceiverView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @EnvironmentObject var audioEngine: AudioEngine
    @EnvironmentObject var telemetryManager: TelemetryManager
    
    @StateObject private var ttsManager = TTSManager()
    @StateObject private var beepGenerator = BeepGenerator()
    
    @State private var isPTTPressed = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // ヘッダー
                HStack {
                    Text("トランシーバー")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
                // 接続状態
                ConnectionStatusView(
                    connectedPeers: networkManager.connectedPeers,
                    availablePeers: networkManager.availablePeers
                )
                
                Spacer()
                
                // PTTボタン
                PTTButton(
                    isPressed: $isPTTPressed,
                    isRecording: audioEngine.isRecording
                )
                .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                    handlePTT(pressing: pressing)
                }, perform: {})
                
                Spacer()
                
                // テレメトリー表示
                if let remoteTelemetry = telemetryManager.remoteTelemetry {
                    TelemetryDisplayView(telemetry: remoteTelemetry)
                        .padding()
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(
                ttsManager: ttsManager,
                beepGenerator: beepGenerator
            )
        }
        .onAppear {
            setupNetworking()
        }
    }
    
    private func setupNetworking() {
        networkManager.startAdvertising()
        networkManager.startBrowsing()
        
        // 音声データ受信時の処理
        networkManager.onAudioDataReceived = { data, peerID in
            audioEngine.playAudio(data: data)
        }
        
        // テレメトリーデータ受信時の処理
        networkManager.onTelemetryReceived = { telemetry, peerID in
            telemetryManager.updateRemoteTelemetry(telemetry)
            
            // TTS読み上げ
            ttsManager.speakTelemetry(telemetry) {
                // TTS終了後にビープ音を再生
                beepGenerator.playBeep(for: telemetry.beepType)
            }
        }
        
        // 音声再生終了時にビープ音を再生
        audioEngine.onPlaybackFinished = {
            if let telemetry = telemetryManager.remoteTelemetry {
                beepGenerator.playBeep(for: telemetry.beepType)
            }
        }
    }
    
    private func handlePTT(pressing: Bool) {
        isPTTPressed = pressing
        
        if pressing {
            // 録音開始
            audioEngine.startRecording()
        } else {
            // 録音停止して送信
            if let audioData = audioEngine.stopRecording() {
                networkManager.sendAudioData(audioData)
                
                // 自分のテレメトリーも送信
                if let telemetry = telemetryManager.currentTelemetry {
                    networkManager.sendTelemetry(telemetry)
                }
            }
        }
    }
}

struct PTTButton: View {
    @Binding var isPressed: Bool
    let isRecording: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: isPressed ? [Color.red, Color.orange] : [Color.blue, Color.cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 200)
                .shadow(color: isPressed ? .red.opacity(0.6) : .blue.opacity(0.6), radius: 20)
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .animation(.spring(response: 0.3), value: isPressed)
            
            VStack(spacing: 10) {
                Image(systemName: isRecording ? "mic.fill" : "mic")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text(isPressed ? "送信中" : "長押しで送信")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
}

struct ConnectionStatusView: View {
    let connectedPeers: [MCPeerID]
    let availablePeers: [MCPeerID]
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Circle()
                    .fill(connectedPeers.isEmpty ? Color.red : Color.green)
                    .frame(width: 12, height: 12)
                
                Text(connectedPeers.isEmpty ? "未接続" : "接続中")
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
            
            if !connectedPeers.isEmpty {
                ForEach(connectedPeers, id: \.self) { peer in
                    Text(peer.displayName)
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                }
            }
            
            if !availablePeers.isEmpty && connectedPeers.isEmpty {
                Text("利用可能なデバイス:")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.caption)
                
                ForEach(availablePeers, id: \.self) { peer in
                    Text(peer.displayName)
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}
