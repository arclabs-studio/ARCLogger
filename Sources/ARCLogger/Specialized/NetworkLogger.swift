import Foundation

/// Specialized logger for HTTP network operations.
///
/// Provides pretty-printed request/response logging with JSON formatting.
public struct NetworkLogger: Sendable {
    private let logger: ARCLogger

    public init(subsystem: String = "com.arclabs-studio.arcnetworking") {
        self.logger = ARCLogger(category: "HTTP", subsystem: subsystem)
    }

    /// Logs an outgoing HTTP request.
    public func logRequest(_ request: URLRequest) {
        #if DEBUG
        var message = """
        ---------------------------------------------
        ➡️ Request: \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "")
        """

        var metadata: [String: String] = [:]

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            let headersString = headers.map { "   \($0): \($1)" }.joined(separator: "\n")
            message += "\n📦 Headers:\n\(headersString)"
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            message += "\n📨 Body:\n\(bodyString)"
            metadata["bodySize"] = "\(body.count) bytes"
        }

        logger.debug(message, metadata: metadata)
        #endif
    }

    /// Logs an HTTP response with formatted JSON if possible.
    public func logResponse(_ response: URLResponse?, data: Data?) {
        #if DEBUG
        guard let httpResponse = response as? HTTPURLResponse else {
            logger.error("No valid HTTPURLResponse")
            return
        }

        var message = """
        ⬅️ Response: \(httpResponse.statusCode) \(httpResponse.url?.absoluteString ?? "")
        """

        var metadata: [String: String] = [
            "statusCode": "\(httpResponse.statusCode)"
        ]

        if let data = data {
            metadata["responseSize"] = "\(data.count) bytes"

            if let jsonString = prettyPrintJSON(data) {
                message += "\n📦 Response JSON:\n\(jsonString)"
            } else if let text = String(data: data, encoding: .utf8), !text.isEmpty {
                message += "\n📦 Response Text:\n\(text)"
            }
        }

        message += "\n----------------------------------------------------------"

        let level: LogLevel = (200..<300).contains(httpResponse.statusCode) ? .debug : .warning

        if level == .debug {
            logger.debug(message, metadata: metadata)
        } else {
            logger.warning(message, metadata: metadata)
        }
        #endif
    }

    /// Logs network-related errors.
    public func logError(_ error: Error, context: String = "") {
        var message = "Network error"
        if !context.isEmpty {
            message += ": \(context)"
        }

        logger.error(message, error: error)
    }

    // MARK: - Private Helpers

    private func prettyPrintJSON(_ data: Data) -> String? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
              let jsonString = String(data: prettyData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}
