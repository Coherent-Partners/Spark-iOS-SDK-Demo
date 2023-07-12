import SwiftUI

struct HomeScreen: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Navigate to:")
                NavigationLink(destination: NativeTestScreen()) {
                    Text("Native View")
                }
                NavigationLink(destination: WebTestScreen()) {
                    Text("Web View")
                }
                Link(destination: URL(string: Constants.sparkSDKLinkAutoCalc)!, label: {
                    Text("Safari View")
                        .foregroundColor(.orange)
                })
            }
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
