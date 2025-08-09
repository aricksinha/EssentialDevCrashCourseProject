import Foundation

public final class Logger {
    public static let shared = Logger()
    private init() { }

    public func log(info: String) {
        print("[INFO] \(info)")
    }

    public func log(error: Error) {
        print("[ERROR] \(error.localizedDescription)")
    }
}