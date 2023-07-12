import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {

    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        WebView(webView: WKWebView(frame: .zero))
    }
}
