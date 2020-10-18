//
//  AirQualityIndexColorTest.swift
//  airQualityTests
//
//  Created by Deni Zakya on 18/10/20.
//

import XCTest

@testable import airQuality

final class AirQualityIndexColorTest: XCTestCase {

    func testGetHealthyColor() {
        let airQualityIndex: UInt = 20

        let airQualityIndexColor = AirQualityIndexColor(airQualityIndex)

        XCTAssertEqual(airQualityIndexColor, .good)
        XCTAssertEqual(airQualityIndexColor?.getColor(), .green)
    }

    func testGetModerateColor() {
        let airQualityIndex: UInt = 70

        let airQualityIndexColor = AirQualityIndexColor(airQualityIndex)

        XCTAssertEqual(airQualityIndexColor, .moderate)
        XCTAssertEqual(airQualityIndexColor?.getColor(), .yellow)
    }

    func testGetUnhealthyForSensitiveColor() {
        let airQualityIndex: UInt = 130

        let airQualityIndexColor = AirQualityIndexColor(airQualityIndex)

        XCTAssertEqual(airQualityIndexColor, .unhealthyForSensitive)
        XCTAssertEqual(airQualityIndexColor?.getColor(), .orange)
    }

    func testGetUnhealthyColor() {
        let airQualityIndex: UInt = 170

        let airQualityIndexColor = AirQualityIndexColor(airQualityIndex)

        XCTAssertEqual(airQualityIndexColor, .unhealthy)
        XCTAssertEqual(airQualityIndexColor?.getColor(), .red)
    }

    func testGetVeryUnhealthyColor() {
        let airQualityIndex: UInt = 270

        let airQualityIndexColor = AirQualityIndexColor(airQualityIndex)

        XCTAssertEqual(airQualityIndexColor, .veryUnhealthy)
        XCTAssertEqual(airQualityIndexColor?.getColor(), .purple)
    }

    func testGetHazardousColor() {
        let airQualityIndex: UInt = 310

        let airQualityIndexColor = AirQualityIndexColor(airQualityIndex)

        XCTAssertEqual(airQualityIndexColor, .hazardous)
        XCTAssertEqual(airQualityIndexColor?.getColor(), UIColor(red: 115.0/255.0, green: 20.0/255.0, blue: 37.0/255.0, alpha: 1.0))
    }

}
