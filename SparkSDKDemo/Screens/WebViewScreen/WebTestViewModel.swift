import WebKit

class WebTestViewModel {

    var urlString = Constants.sparkSDKLinkAutoCalc

    let webView: WKWebView
    init() {
        webView = WKWebView(frame: .zero)
    }

    func loadUrl() {
        guard let url = URL(string: urlString) else {
            return
        }
        webView.load(URLRequest(url: url))
    }

    func getOutput() {
        webView.evaluateJavaScript("document.getElementById(\"log\").textContent") { result, error in
            if let err = error {
                print(err)
            } else {
                print(result ?? "")
            }
        }
    }
}
