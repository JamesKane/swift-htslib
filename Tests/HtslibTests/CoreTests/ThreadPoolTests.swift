import Testing
@testable import Htslib

@Suite("ThreadPool")
struct ThreadPoolTests {
    @Test func createPool() throws {
        let pool = try ThreadPool(threads: 2)
        #expect(pool.size == 2)
    }

    @Test func createPoolWithOneThread() throws {
        let pool = try ThreadPool(threads: 1)
        #expect(pool.size == 1)
    }

    @Test func poolWithFileThreads() throws {
        let pool = try ThreadPool(threads: 2)
        let path = testDataPath("ce#1.sam")
        let file = try HTSFile(path: path, mode: "r")
        let ret = file.setThreadPool(pool)
        #expect(ret == 0)
    }
}
