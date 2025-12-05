# Xcodeプロジェクトの作成手順

## 問題
古いプロジェクトファイルをコピーしたため、テストファイルの依存関係エラーが発生しています。

## 解決方法：Xcodeで新規プロジェクトを作成

### 手順

1. **Xcodeを開く**
   - Xcode を起動
   - "Create New Project" をクリック

2. **テンプレートを選択**
   - iOS > App を選択
   - Next をクリック

3. **プロジェクト設定**
   - Product Name: `TelemetryTransceiver`
   - Team: あなたの開発チーム（または空欄）
   - Organization Identifier: `com.telemetry`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - ✅ Use Core Data: **チェックを外す**
   - ✅ Include Tests: **チェックを外す**（重要！）
   - Next をクリック

4. **保存場所**
   - `/Users/resoto/Desktop/ios1/` を選択
   - プロジェクト名を `TelemetryTransceiver` に設定
   - Create をクリック

5. **既存のファイルを追加**
   
   プロジェクトナビゲーターで `TelemetryTransceiver` フォルダを右クリック：
   
   a. **Add Files to "TelemetryTransceiver"** を選択
   
   b. 以下のフォルダを選択して追加：
   - `TelemetryTransceiver/Audio`（フォルダごと）
   - `TelemetryTransceiver/Telemetry`（フォルダごと）
   - `TelemetryTransceiver/Network`（フォルダごと）
   - `TelemetryTransceiver/Models`（フォルダごと）
   - `TelemetryTransceiver/Views`（フォルダごと）
   
   c. オプション設定：
   - ✅ "Copy items if needed" にチェック
   - ✅ "Create groups" を選択
   - ✅ Target: TelemetryTransceiver にチェック
   
   d. Add をクリック

6. **Info.plistを置き換え**
   
   - プロジェクトナビゲーターで既存の `Info.plist` を削除
   - `TelemetryTransceiver/Info.plist` を追加（上記と同じ手順）

7. **Assets.xcassetsを置き換え**
   
   - 既存の `Assets.xcassets` を削除
   - `TelemetryTransceiver/Assets.xcassets` を追加

8. **既存のContentView.swiftとAppファイルを置き換え**
   
   - `ContentView.swift` を削除
   - `TelemetryTransceiverApp.swift` を削除
   - 代わりに以下を追加：
     - `TelemetryTransceiver/ContentView.swift`
     - `TelemetryTransceiver/TelemetryTransceiverApp.swift`

9. **ビルド設定**
   
   プロジェクト設定 > Signing & Capabilities:
   - Team を選択（または Automatically manage signing にチェック）
   - Bundle Identifier が `com.telemetry.TelemetryTransceiver` になっていることを確認

10. **ビルドして実行**
    - Product > Build (⌘B)
    - エラーがないことを確認
    - シミュレータまたは実機で実行

## より簡単な方法（推奨）

すべてのファイルは既に `/Users/resoto/Desktop/ios1/TelemetryTransceiver/TelemetryTransceiver/` に配置されています。

Xcodeで新規プロジェクトを作成する際に、**既存のフォルダを上書きしないように注意**してください。

または、以下のコマンドでXcodeGenを使用してプロジェクトを自動生成できます（Homebrewのインストールが完了後）：

```bash
cd /Users/resoto/Desktop/ios1/TelemetryTransceiver
xcodegen generate
open TelemetryTransceiver.xcodeproj
```

## トラブルシューティング

### ファイルが見つからない
- Xcodeのプロジェクトナビゲーターで、ファイルを右クリック > Show in Finder で場所を確認

### ビルドエラー
- Product > Clean Build Folder (⌘⇧K)
- Xcodeを再起動

### 権限エラー
- Info.plistに必要な権限が含まれていることを確認
