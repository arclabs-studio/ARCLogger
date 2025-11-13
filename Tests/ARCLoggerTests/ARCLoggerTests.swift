import Testing
@testable import ARCLogger

struct ARCLoggerTests {
    @Test
    func testHelloFunction() {
        #expect(ARCLogger.hello() == "Hello from ARCLogger!")
    }
}
