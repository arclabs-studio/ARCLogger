import Foundation
@testable import ARCLogger

enum LogTestHelpers {

    /// Creates a test logger with a mock destination.
    static func makeTestLogger(
        category: String = "Test",
        subsystem: String = "com.test",
        minimumLevel: LogLevel = .debug
    ) -> (logger: ARCLogger, mock: MockLogDestination) {
        let mock = MockLogDestination(minimumLevel: minimumLevel)
        let logger = ARCLogger(
            destinations: [mock],
            subsystem: subsystem,
            category: category
        )
        return (logger, mock)
    }

    /// Creates a sample URLRequest for testing.
    static func makeSampleRequest(
        method: String = "GET",
        url: String = "https://api.example.com/users",
        headers: [String: String]? = nil,
        body: Data? = nil
    ) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        return request
    }

    /// Creates a sample HTTPURLResponse for testing.
    static func makeSampleResponse(
        url: String = "https://api.example.com/users",
        statusCode: Int = 200
    ) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: url)!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    /// Sample JSON data for testing.
    static var sampleJSONData: Data {
        """
        {
            "id": 42,
            "name": "John Doe",
            "email": "john@example.com"
        }
        """.data(using: .utf8)!
    }
}
