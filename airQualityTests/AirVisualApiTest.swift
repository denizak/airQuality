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

    func testGetCities() throws {
        let api = AirVisualApi()
        let country = "Indonesia"
        let state = "Bali"

        let cities = try api.getCities(of: state, country: country)
            .toBlocking().first()!

        XCTAssertGreaterThan(cities.count, 0)
        XCTAssertEqual(cities.first!, "Denpasar")
    }

    func testGetNearestCityData() throws {
        let api = AirVisualApi()

        let nearestCityData = try api.getNearestCityInfo().toBlocking().first()

        XCTAssertNotNil(nearestCityData)
        XCTAssertFalse(nearestCityData!.city.isEmpty)
        XCTAssertNotNil(nearestCityData!.weather.timestamp)
        XCTAssertNotNil(nearestCityData!.pollution.timestamp)
    }

}
