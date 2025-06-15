
import Foundation

extension Data {
    func asString() -> String {
        return String(data:self, encoding: .utf8) ?? ""
    }
}

extension Encodable {
    func asData() -> Data? {
        return try? JSONEncoder().encode(self)
    }
}
