//
//  CityData.swift
//  airQuality
//
//  Created by Deni Zakya on 18/10/20.
//

import Foundation

struct CityData: Equatable {
    let city: String
    let state: String
    let country: String
    let location: CityLocation?
    let weather: CityWeather
    let pollution: CityPollution
}

struct CityLocation: Equatable {
    let latitude: Double
    let longitude: Double
}

struct CityWeather: Equatable {
    let timestamp: Date?
    let temperature: Int
    let pressure: Int
    let humidity: Int
    let windSpeed: Double
    let windDirection: Int
    let icon: String
}

struct CityPollution: Equatable {
    let timestamp: Date?
    let airQualityIndexUS: Int
    let mainPollutantUS: String
    let airQualityIndexChina: Int
    let mainPollutantChina: String
}
