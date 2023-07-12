import Foundation
import UIKit
extension String {
    func convertToDictionary() -> [String: AnyObject]? {
        if let data = self.data(using: .utf8) {
            do {
                let json = try JSONSerialization
                    .jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
}

extension FileManager {
    func getDocumentsDirectory() -> URL? {
        let documentsUrl = self.urls(for: .documentDirectory,
                                     in: .userDomainMask)
        return documentsUrl.first
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
