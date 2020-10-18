//
//  AirVisualApiTest.swift
//  airQualityTests
//
//  Created by Deni Zakya on 17/10/20.
//

import XCTest

import RxBlocking

@testable import airQuality

final class AirVisualApiTest: XCTestCase {

    func testGetCountries() throws {
        let api = AirVisualApi()

        let countries = try api.getCountries().toBlocking().first()!

        XCTAssertGreaterThan(countries.count, 0)
        XCTAssertEqual(countries.first, "Afghanistan")
        XCTAssertEqual(countries.last, "Yemen")
    }

    func testGetStates() throws {
        let api = AirVisualApi()
        let country = "Indonesia"

        let states = try api.getStates(of: country).toBlocking().first()!

        XCTAssertGreaterThan(states.count, 0)
        XCTAssertEqual(states.first, "Bali")
    }

}
