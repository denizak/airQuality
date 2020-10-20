//
//  CitySelectionStorageTest.swift
//  airQualityTests
//
//  Created by Deni Zakya on 20/10/20.
//

import XCTest

@testable import airQuality

final class CitySelectionStorageTest: XCTestCase {

    func testGet() {
        let storage = CitySelectionStorage(inMemory: true)

        let emptyRows = storage.get()
        XCTAssertEqual(emptyRows.count, 0)

        let insertStatus = storage.insert(city: "City 1", state: "State 1", country: "Country 1")
        XCTAssertGreaterThan(insertStatus, 0)
        let rows = storage.get()
        XCTAssertGreaterThan(rows.count, 0)
    }

}
