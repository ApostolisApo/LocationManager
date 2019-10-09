import XCTest
@testable import LocationManager

final class LocationManagerTests: XCTestCase {
    func testCoordinatesEqual() {
        let coordinates1 = Coordinates(withLatitude: 10.0, andLongitude: 11.0)
        let coordinates2 = Coordinates(withLatitude: 10.0, andLongitude: 11.0)
        assert(coordinates1 == coordinates2)
    }

    static var allTests = [
        ("testExample", testCoordinatesEqual),
    ]
}
