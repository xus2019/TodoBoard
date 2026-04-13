import SwiftUI

struct MarkdownPreviewView: View {
    let content: String

    var body: some View {
        ScrollView {
            Text(MarkdownRenderer.render(content))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
}
