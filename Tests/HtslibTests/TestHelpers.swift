import Foundation

func testDataPath(_ filename: String) -> String {
    Bundle.module.url(forResource: "TestData", withExtension: nil)!
        .appendingPathComponent(filename).path
}

func tempFilePath(_ name: String) -> String {
    NSTemporaryDirectory() + "/swift-htslib-test-" + name
}
