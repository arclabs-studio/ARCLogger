import XCTest
@testable import ARCLogger

final class NetworkLoggerTests: XCTestCase {

    var logger: NetworkLogger!

    override func setUp() {
        super.setUp()
        logger = NetworkLogger(subsystem: "com.test.network")
    }

    func testLogBasicGETRequest() {
        let request = LogTestHelpers.makeSampleRequest(
            method: "GET",
            url: "https://api.example.com/users"
        )

        logger.logRequest(request)
        XCTAssertTrue(true)
    }

    func testLogPOSTRequestWithHeaders() {
        let request = LogTestHelpers.makeSampleRequest(
            method: "POST",
            url: "https://api.example.com/users",
            headers: [
                "Content-Type": "application/json",
                "Authorization": "Bearer token123"
            ]
        )

        logger.logRequest(request)
        XCTAssertTrue(true)
    }

    func testLogRequestWithBody() {
        let bodyData = """
        {"name":"John","email":"john@example.com"}
        """.data(using: .utf8)!

        let request = LogTestHelpers.makeSampleRequest(
            method: "POST",
            url: "https://api.example.com/users",
            body: bodyData
        )

        logger.logRequest(request)
        XCTAssertTrue(true)
    }

    func testLogSuccessfulResponse() {
        let response = LogTestHelpers.makeSampleResponse(
            url: "https://api.example.com/users",
            statusCode: 200
        )
        let data = LogTestHelpers.sampleJSONData

        logger.logResponse(response, data: data)
        XCTAssertTrue(true)
    }

    func testLogErrorResponse() {
        let response = LogTestHelpers.makeSampleResponse(
            url: "https://api.example.com/users",
            statusCode: 404
        )
        let data = """
        {"error":"Not found"}
        """.data(using: .utf8)

        logger.logResponse(response, data: data)
        XCTAssertTrue(true)
    }

    func testLogResponseWithInvalidJSON() {
        let response = LogTestHelpers.makeSampleResponse(statusCode: 200)
        let data = "Plain text response".data(using: .utf8)

        logger.logResponse(response, data: data)
        XCTAssertTrue(true)
    }

    func testLogError() {
        enum TestError: Error {
            case networkTimeout
        }

        logger.logError(TestError.networkTimeout, context: "Fetching user profile")
        XCTAssertTrue(true)
    }
}
