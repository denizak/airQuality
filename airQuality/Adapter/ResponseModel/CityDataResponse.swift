//
//  CityInfoResponse.swift
//  airQuality
//
//  Created by Deni Zakya on 18/10/20.
//

import Foundation

struct CityDataResponse: Decodable {
    let status: String
    let data: CityDataDetailResponse
}

struct CityDataDetailResponse: Decodable {
    let city: String
    let state: String
    let country: String
    let location: CityDataLocationResponse
    let current: CityDataCurrentResponse
}

struct CityDataLocationResponse: Decodable {
    let type: String
    let coordinates: [Double]
}

struct CityDataCurrentResponse: Decodable {
    let weather: CityDataWeather
    let pollution: CityDataPollutionResponse
}

struct CityDataWeather: Decodable  {
    let timestamp: String
    let temperature: Int
    let pressure: Int
    let humidity: Int
    let windSpeed: Double
    let windDirection: Int
    let iconCode: String

    enum CodingKeys: String, CodingKey {
        case timestamp = "ts"
        case temperature = "tp"
        case pressure = "pr"
        case humidity = "hu"
        case windSpeed = "ws"
        case windDirection = "wd"
        case iconCode = "ic"
    }
}

struct CityDataPollutionResponse: Decodable {
    let timestamp: String
    let airQualityIndexUS: Int
    let mainPollutantUS: String
    let airQualityIndexChina: Int
    let mainPollutantChina: String

    enum CodingKeys: String, CodingKey {
        case timestamp = "ts"
        case airQualityIndexUS = "aqius"
        case mainPollutantUS = "mainus"
        case airQualityIndexChina = "aqicn"
        case mainPollutantChina = "maincn"
    }
}
