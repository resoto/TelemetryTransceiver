import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("テスト")
                .font(.largeTitle)
                .padding()
            Text("アプリが起動しました")
                .foregroundColor(.blue)
        }
    }
}

#Preview {
    ContentView()
}
