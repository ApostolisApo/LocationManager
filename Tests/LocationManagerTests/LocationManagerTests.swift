import XCTest
@testable import LocationManager

final class LocationManagerTests: XCTestCase {
    func testCoordinatesEqual() {
        let coordinates1 = Coordinates(withLatitude: 57.72863667097471, andLongitude: 11.970982871291888)
        let coordinates2 = Coordinates(withLatitude: 57.72863667097471, andLongitude: 11.970982871291888)
        assert(coordinates1 == coordinates2)
    }

    static var allTests = [
        ("testExample", testCoordinatesEqual),
    ]
}
