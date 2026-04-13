import SwiftUI

struct StatusBarView: View {
    @ObservedObject var viewModel: WorkspaceViewModel
    @ObservedObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 16) {
            SettingsLink {
                Image(systemName: "gearshape")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(themeManager.textSecondary)
            }
            .buttonStyle(.plain)

            HStack(spacing: 5) {
                Circle()
                    .fill(themeManager.accentColor)
                    .frame(width: 6, height: 6)
                Text("待办 \(viewModel.todoCount)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(themeManager.textSecondary)
            }

            HStack(spacing: 5) {
                Circle()
                    .fill(Color.green.opacity(0.7))
                    .frame(width: 6, height: 6)
                Text("已完成 \(viewModel.doneCount)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(themeManager.textSecondary)
            }

            // Inline progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(themeManager.isDark ? Color.white.opacity(0.06) : Color.black.opacity(0.06))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(themeManager.accentColor.opacity(0.7))
                        .frame(width: max(0, geo.size.width * viewModel.completionRate))
                }
            }
            .frame(width: 80, height: 4)

            Text("\(String(format: "%.0f", viewModel.completionRate * 100))%")
                .font(.system(size: 11, weight: .medium).monospacedDigit())
                .foregroundStyle(themeManager.textSecondary)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
        .background(themeManager.isDark ? Color.white.opacity(0.02) : Color.black.opacity(0.02))
    }
}
