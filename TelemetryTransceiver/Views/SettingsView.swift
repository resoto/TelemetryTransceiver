import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var ttsManager: TTSManager
    @ObservedObject var beepGenerator: BeepGenerator
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("音声設定")) {
                    Toggle("TTS読み上げ", isOn: $ttsManager.isEnabled)
                    Toggle("ビープ音", isOn: $beepGenerator.isEnabled)
                }
                
                Section(header: Text("ビープ音テスト")) {
                    Button("通常ビープ (ピッ)") {
                        beepGenerator.playBeep(for: .normal)
                    }
                    
                    Button("停滞ビープ (プゥ)") {
                        beepGenerator.playBeep(for: .stationary)
                    }
                    
                    Button("バッテリー警告 (ピピピッ)") {
                        beepGenerator.playBeep(for: .batteryWarning)
                    }
                    
                    Button("緊急 (ピーピーピー)") {
                        beepGenerator.playBeep(for: .emergency)
                    }
                }
                
                Section(header: Text("情報")) {
                    HStack {
                        Text("デバイス名")
                        Spacer()
                        Text(UIDevice.current.name)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}
