import Combine
import Foundation
import SparkSDK
import WebKit
import ZIPFoundation

struct InputFile: Hashable {
    let name: String
    let path: String
}

class NativeTestViewModel: ObservableObject {

    var sparkSDK: SparkiOSSDK?

    @Published var output: String = ""
    @Published var error: String = ""
    @Published var executionTime = [String]()
    @Published var isSDKReady: Bool = false
    @Published var inputs = [InputFile]()
    @Published var isLoading: Bool = false

    private var resultCancellable: AnyCancellable?

    var executeRequests = [String: Double]()

    var initStartTime: Double = 0

    let sparkFactory: SparkSDKFactory

    init(webView: WKWebView) {
        sparkFactory = SparkSDKFactory(webView: webView)
        populateInputs()
    }

    func initializeSDKFromBundle() {
        let path = Bundle.main.bundlePath
        let modelsPath = "\(path)/assets"
        let modelsURL = URL(fileURLWithPath: modelsPath)
        initializeSparkSDK(resourcesPath: modelsURL.absoluteString)
    }

    func initializeSDKFromDocumentsDirectory() {
        unzipModels()
        let documentsUrl = FileManager.default.getDocumentsDirectory()
        initializeSparkSDK(resourcesPath: documentsUrl!.absoluteString)
    }

    private func initializeSparkSDK(resourcesPath: String) {
        print("Initiating request")
        isLoading = true
        initStartTime = CFAbsoluteTimeGetCurrent()

        sparkFactory.requestSDK(
            modelsPath: resourcesPath,
            enableLogging: false,
            onSDKReady: { [weak self] sdkResult in
                guard let self = self else { return }

                let diff = CFAbsoluteTimeGetCurrent() - self.initStartTime
                let timeLog = "Initialisation took \(String(format: "%0.3f", diff)) sec to run"
                self.executionTime.append("\(timeLog)\n\n")
                print(timeLog)

                print("requestSDK Result: \(sdkResult)")
                switch sdkResult {
                case .success(let sdk):
                    self.sparkSDK = sdk
                    self.isSDKReady = true
                    self.observeExecutionResult()
                    self.isLoading = false

                case .failure(let error):
                    print("SDK initialisation failed: \(error)")
                    self.isLoading = false
                }
            }
        )
    }

    private func observeExecutionResult() {
        resultCancellable = sparkSDK?.$executionResponses
            .dropFirst()
            .sink(receiveValue: { [weak self] value in
                self?.isLoading = false
                switch value {
                case .success(let executionResult):
                    if let startTime = self?.executeRequests[executionResult.requestId] {
                        let diff = CFAbsoluteTimeGetCurrent() - startTime
                        let timeLog = "\(executionResult.requestId) : took \(String(format: "%0.3f", diff)) sec to run"
                        self?.executionTime.append("\(timeLog)\n\n")
                        print(timeLog)
                    }

                    self?.output = (executionResult.result as? [String: Any])?.description ?? ""
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            })
    }

    func execute(input: InputFile) {
        let url = URL(string: input.path)
        if let jsonData = try? String(contentsOf: url!) {
            let convertedDict = jsonData.convertToDictionary()!

            let requestId = UUID().uuidString
            isLoading = true
            executeRequests[requestId] = CFAbsoluteTimeGetCurrent()
            sparkSDK?.execute(requestId: requestId, input: convertedDict)
        }
    }

    private func unzipModels() {
        let zippedModels = Bundle.main.resourceURL?.appendingPathComponent("assets/zipped-models.zip")

        let fileManager = FileManager.default
        let documentsUrl = fileManager.getDocumentsDirectory()

        if let destinationURL = documentsUrl, let zippedModels = zippedModels {
            print("Doc directory path : \(destinationURL)")

            do {
                try fileManager.unzipItem(at: zippedModels, to: destinationURL)
            } catch {
                print("Extraction of ZIP archive failed with error:\(error)")
            }
        }
    }

    func populateInputs() {
        let path = Bundle.main.bundlePath
        let inputsPath =  "\(path)/inputs"
        let inputURL = URL(fileURLWithPath: inputsPath)
        let urls = getAllFiles(from: inputURL.absoluteString)

        let inputFiles = urls.compactMap { (url) -> InputFile? in
            return InputFile(name: url.lastPathComponent, path: url.absoluteString)
        }

        inputs.removeAll()
        inputs.append(contentsOf: inputFiles)
    }

    func getAllFiles(from folder: String) -> [URL] {

        var files = [URL]()
        if let url = URL(string: folder) {
            if let enumerator = FileManager.default.enumerator(at: url,
                                                               includingPropertiesForKeys: [.isRegularFileKey],
                                                               options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                for case let fileURL as URL in enumerator {
                    do {
                        let fileAttributes = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                        if fileAttributes.isRegularFile! {
                            files.append(fileURL)
                        }
                    } catch { print(error, fileURL) }
                }
            }
        }
        return files
    }

    deinit {
        resultCancellable?.cancel()
        resultCancellable = nil
    }
}
