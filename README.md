# テレメトリー付きトランシーバー

音声通信に加えて、テレメトリーデータを音声で伝達するiOSトランシーバーアプリです

## 主な機能

### 1. 音声通信
- **Push-to-Talk (PTT)**: 大きなボタンを長押しして音声を送信
- **リアルタイム音声**: 低遅延での音声通信
- **ピアツーピア接続**: Multipeer Connectivityによるローカルネットワーク通信

### 2. テレメトリーデータ収集
- **GPS情報**: 緯度、経度、標高
- **バッテリー残量**: デバイスのバッテリー状態
- **動き検出**: 加速度センサーによる移動/停滞の判定

### 3. 耳で見るインターフェース

#### TTS自動読み上げ
相手が話し終わった後、システム音声で重要なデータを読み上げます。

例：「標高2800メートル、バッテリー低下、残り15パーセント」

#### ダイナミックビープ音
相手の状態に応じて変化する送信終了音：

- **通常状態** (移動中、バッテリー十分): 高音の「ピッ」
- **停滞中**: 低音の「プゥ」
- **バッテリー警告** (15%以下): 「ピピピッ」
- **緊急**: 「ピーピーピー」

## プロジェクト構成

```
TelemetryTransceiver/
├── Audio/
│   ├── AudioEngine.swift       # 音声録音・再生エンジン
│   ├── AudioMixer.swift        # TTS音声とボイスのミキシング
│   ├── TTSManager.swift        # Text-to-Speech管理
│   └── BeepGenerator.swift     # ダイナミックビープ音生成
├── Telemetry/
│   └── TelemetryManager.swift  # GPS、バッテリー、動き検出
├── Network/
│   └── NetworkManager.swift    # Multipeer Connectivity
├── Models/
│   ├── TelemetryData.swift     # テレメトリーデータモデル
│   └── DataPacket.swift        # ネットワークパケット
└── Views/
    ├── TransceiverView.swift   # メインビュー
    ├── TelemetryDisplayView.swift  # テレメトリー表示
    └── SettingsView.swift      # 設定画面
```

## ビルド方法

### 必要要件
- Xcode 15.0以上
- iOS 16.0以上
- 実機 (シミュレータではMultipeer Connectivityが制限されます)

### ビルド手順

1. Xcodeでプロジェクトを開く:
```bash
cd /Users/resoto/Desktop/ios1/TelemetryTransceiver
open TelemetryTransceiver.xcodeproj
```

2. Xcodeで:
   - ターゲットを `transceiver` に設定
   - デバイスまたはシミュレータを選択
   - Product > Build (⌘B)

3. 実機でテストする場合:
   - Signing & Capabilities で Development Team を設定
   - 2台のデバイスにインストール

## 使い方

### 初回起動時
アプリは以下の権限を要求します：
- **マイク**: 音声通信のため
- **位置情報**: 標高データ取得のため
- **ローカルネットワーク**: ピアツーピア通信のため

### 基本操作

1. **接続**
   - アプリを起動すると自動的に近くのデバイスを検索
   - 接続状態は画面上部に表示

2. **音声送信**
   - 中央の大きなボタンを長押し
   - 話す
   - ボタンを離すと送信完了

3. **音声受信**
   - 相手の音声が自動的に再生
   - 音声終了後、TTSでテレメトリーデータを読み上げ
   - 最後に状態に応じたビープ音が鳴る

4. **設定**
   - 右上の歯車アイコンをタップ
   - TTS読み上げのON/OFF
   - ビープ音のON/OFF
   - ビープ音のテスト再生

## 技術詳細

### 音声処理
- **AVAudioEngine**: 音声録音・再生
- **AVSpeechSynthesizer**: 日本語TTS
- **AVAudioPlayerNode**: ビープ音生成

### テレメトリー
- **CoreLocation**: GPS、標高データ
- **UIDevice**: バッテリー情報
- **CoreMotion**: 加速度センサー

### ネットワーク
- **MultipeerConnectivity**: ピアツーピア通信
- **Bonjour**: デバイス検出

## トラブルシューティング

### 接続できない
- 両方のデバイスでBluetoothとWi-Fiがオンになっているか確認
- ローカルネットワーク権限が許可されているか確認
- 同じネットワークに接続しているか確認

### 音声が聞こえない
- マイク権限が許可されているか確認
- デバイスの音量を確認
- 設定でTTS/ビープ音が有効になっているか確認

### 標高データが表示されない
- 位置情報権限が許可されているか確認
- 屋外で使用する (GPS信号が必要)

## ライセンス

このプロジェクトは教育目的で作成されました。
