import SwiftUI

struct WebTestScreen: View {

    private let viewModel = WebTestViewModel()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button("Execute Input") {
                    viewModel.loadUrl()
                }
                Spacer()
                Button("Get Output") {
                    viewModel.getOutput()
                }
            }.padding(.horizontal)
            WebView(webView: viewModel.webView)
        }
    }
}

struct WebTestScreen_Previews: PreviewProvider {
    static var previews: some View {
        WebTestScreen()
    }
}
