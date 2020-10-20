//
//  CityDataStorageTest.swift
//  airQualityTests
//
//  Created by Deni Zakya on 20/10/20.
//

import XCTest

@testable import airQuality

final class CityDataStorageTest: XCTestCase {

    func testGet() {
        let expectedCityData = sampleCityData()
        let storage = CityDataStorage(inMemory: true)

        let nilData = storage.get(city: "", state: "", country: "")
        XCTAssertNil(nilData)

        let result = storage.insert(cityData: sampleCityData())

        XCTAssertGreaterThan(result, 0)
        let cityData = storage.get(city: "City 1", state: "State 1", country: "Country 1")
        XCTAssertEqual(cityData, expectedCityData)
    }

    private func sampleCityData() -> CityData {
        CityData(city: "City 1", state: "State 1", country: "Country 1",
                 location: nil,
                 weather: CityWeather(timestamp: nil,
                                      temperature: 10,
                                      pressure: 10,
                                      humidity: 10,
                                      windSpeed: 10,
                                      windDirection: 10,
                                      icon: "icon"),
                 pollution: CityPollution(timestamp: nil,
                                          airQualityIndexUS: 10,
                                          mainPollutantUS: "",
                                          airQualityIndexChina: 0,
                                          mainPollutantChina: ""))
    }

}
