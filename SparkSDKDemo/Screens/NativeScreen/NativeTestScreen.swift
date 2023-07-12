import SwiftUI
import WebKit

struct NativeTestScreen: View {

    private let webView: WKWebView

    @ObservedObject var viewModel: NativeTestViewModel
    @State var selectedItem = InputFile(name: "Select Input", path: "")

    init() {
        self.webView = WKWebView(frame: .zero)
        self.viewModel = NativeTestViewModel(webView: webView)
        self._selectedItem = State(initialValue: viewModel.inputs[0])
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                }
                Group {
                    HStack {
                        Picker(selectedItem.name, selection: $selectedItem) {
                            ForEach(viewModel.inputs, id: \.self) { item in
                                Text(item.name)
                            }
                        }.pickerStyle(.menu)
                        Spacer()
                        Button("Execute Input") {
                            viewModel.execute(input: selectedItem)
                        }.disabled(!viewModel.isSDKReady)
                    }
                }.modifier(CustomBoxViewModifier())
                WebView(webView: webView)
                    .frame(height: 0)
                    .onAppear {
                        viewModel.initializeSDKFromBundle()
                    }

                HStack {
                    if viewModel.isLoading {
                        HStack(spacing: 15) {
                            ProgressView()
                            Text("Loading…")
                        }.frame(maxWidth: .infinity)
                    }
                }

                Text("Output :").padding(.top)
                Group {
                    OutputView(output: $viewModel.output)
                        .frame(height: 250)
                }.modifier(CustomBoxViewModifier())
                Text("Error :")
                Group {
                    ScrollView {
                        Text(viewModel.error).frame(maxWidth: .infinity)
                    }.frame(height: 100)
                }.modifier(CustomBoxViewModifier())
                Text("Execution Time :")
                Group {
                    ScrollView {
                        Text(viewModel.executionTime.joined()).frame(maxWidth: .infinity)
                    }.frame(height: 100)
                }.modifier(CustomBoxViewModifier())

            }.padding().onTapGesture {
                self.endEditing()
            }
        }
    }

    private func endEditing() {
        UIApplication.shared.endEditing()
    }
}

struct OutputView: View {
    @Binding var output: String
    var body: some View {
        TextEditor(text: .constant(output))
    }

}

struct CustomBoxViewModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .padding().cornerRadius(8.0)
            .overlay(
                RoundedRectangle(cornerRadius: 8.0).stroke(Color.gray, lineWidth: 1)
            )
    }
}

struct NativeTestScreen_Previews: PreviewProvider {
    static var previews: some View {
        NativeTestScreen()
    }
}
