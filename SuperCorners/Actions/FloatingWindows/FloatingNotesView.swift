import SwiftUI

struct FloatingNotesView: View {
    @State private var text: String = ""
    @AppStorage("savedNote") private var savedNote = ""

    var body: some View {
        VStack {
            Text("Notes")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)

            TextEditor(text: $text)
                .font(.body)
                .padding(4)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                .padding()
        }
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
        .frame(width: 300, height: 300)
        .cornerRadius(12)
        .onAppear {
            text = savedNote
        }
        .onChange(of: text) { newValue in
            savedNote = newValue
        }
    }
}
