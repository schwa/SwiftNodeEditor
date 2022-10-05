@testable import SwiftNodeEditor
import XCTest

final class OrderedIDSetTests: XCTestCase {
    func test1() throws {
        struct Thing: Identifiable, Equatable {
            let id: String
            let value: String
        }

        var set = OrderedIDSet<Thing>()
        XCTAssertEqual(set.count, 0)
        XCTAssertTrue(set.isEmpty)
        set.insert(.init(id: "A", value: "1"))
        XCTAssertFalse(set.isEmpty)
        XCTAssertTrue(set.contains(set[0]))
        XCTAssertEqual(set[0].value, "1")
        XCTAssertEqual(set[id: "A"]?.value, "1")
        set.insert(.init(id: "B", value: "2"))
        set.insert(.init(id: "C", value: "3"))
        XCTAssertEqual(set.count, 3)
        XCTAssertEqual(set.map(\.value), ["1", "2", "3"])
        set[id: "B"] = nil
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set.map(\.value), ["1", "3"])
        set.insert(.init(id: "B", value: "4"))
        XCTAssertEqual(set.map(\.value), ["1", "3", "4"])
    }
}
