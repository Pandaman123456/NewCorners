import SwiftUI

struct FloatingCalculatorView: View {
    @State private var input = "0"
    @State private var previousInput = ""
    @State private var operation: String? = nil

    // Simple calc logic
    let buttons = [
        ["7", "8", "9", "÷"],
        ["4", "5", "6", "×"],
        ["1", "2", "3", "-"],
        ["C", "0", "=", "+"]
    ]

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Text(input)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
                    .padding()
            }
            .background(Color.black.opacity(0.3))
            .cornerRadius(8)

            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { button in
                        Button(action: {
                            handleButton(button)
                        }) {
                            Text(button)
                                .font(.title2)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(isOperation(button) ? .orange : .gray)
                    }
                }
            }
        }
        .padding()
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
        .frame(width: 250, height: 350)
        .cornerRadius(12)
    }

    func isOperation(_ btn: String) -> Bool {
        return ["÷", "×", "-", "+", "="].contains(btn)
    }

    func handleButton(_ btn: String) {
        if let num = Int(btn) {
            if input == "0" { input = "\(num)" }
            else { input += "\(num)" }
        } else if btn == "C" {
            input = "0"
            previousInput = ""
            operation = nil
        } else if ["÷", "×", "-", "+"].contains(btn) {
            previousInput = input
            operation = btn
            input = "0"
        } else if btn == "=" {
            calculate()
        }
    }

    func calculate() {
        guard let op = operation, let prev = Double(previousInput), let curr = Double(input) else { return }
        var result: Double = 0
        switch op {
        case "+": result = prev + curr
        case "-": result = prev - curr
        case "×": result = prev * curr
        case "÷": result = (curr != 0) ? prev / curr : 0
        default: break
        }

        input = formatResult(result)
        operation = nil
    }

    func formatResult(_ val: Double) -> String {
        if val.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", val)
        }
        return String(format: "%.2f", val)
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
