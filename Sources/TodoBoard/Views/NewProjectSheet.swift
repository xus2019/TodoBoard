import SwiftUI

struct NewProjectSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var color = Color(hex: "#4A90D9")

    let onCreate: (String, String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("新建项目")
                .font(.title3.bold())

            NativeTextField(
                placeholder: "项目名称",
                text: $name,
                becomesFirstResponder: true,
                onSubmit: { createProject() }
            )
            .frame(height: 22)

            HStack {
                Text("项目颜色")
                    .foregroundStyle(.secondary)
                Spacer()
                ColorPicker("", selection: $color, supportsOpacity: false)
                    .labelsHidden()
            }

            HStack {
                Spacer()
                Button("取消") {
                    dismiss()
                }
                Button("创建") {
                    createProject()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.trimmed.isEmpty)
            }
        }
        .padding()
        .frame(width: 360)
    }

    private func createProject() {
        guard !name.trimmed.isEmpty else { return }
        let hex = color.hexString ?? "#4A90D9"
        onCreate(name.trimmed, hex)
        dismiss()
    }
}
