import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "macwindow.on.rectangle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundStyle(.blue)

            Text("Super Corners")
                .font(.title)
                .fontWeight(.bold)

            Text("Version 2.0")
                .foregroundStyle(.secondary)

            Text("A modern, intuitive implementation of corner actions for macOS.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}
