//
//  AirVisualApi.swift
//  airQuality
//
//  Created by Deni Zakya on 17/10/20.
//

import Foundation

import RxSwift
import RxCocoa

typealias CountryName = String
typealias StateName = String
typealias CityName = String

enum APIError: Error {
    case failedToCreateURL
}

protocol CityDataApi {
    func getCountries() -> Observable<[CountryName]>
    func getStates(of country: String) -> Observable<[StateName]>
    func getCities(of state: String, country: String) -> Observable<[CityName]>
    func getNearestCityData() -> Observable<CityData>
    func getCityData(_ city: String, state: String, country: String) -> Observable<CityData>
}

final class AirVisualApi: CityDataApi {

    private let apiKey = "380074c3-c22c-4bfc-9b00-b666017b344f"
    private let host = "api.airvisual.com"

    func getCountries() -> Observable<[CountryName]> {
        guard let url = createURL(host: host,
                                  path: "countries",
                                  key: apiKey)
        else { return Observable.error(APIError.failedToCreateURL) }

        let urlRequest = URLRequest(url: url)

        return URLSession.shared.rx.data(request: urlRequest)
            .map {
                try JSONDecoder().decode(CountryResponse.self, from: $0)
            }
            .map { $0.data.map { $0.country } }
    }

    func getStates(of country: String) -> Observable<[StateName]> {
        guard let url = createURL(host: host,
                                  path: "states",
                                  key: apiKey,
                                  param: ["country": country])
        else { return Observable.error(APIError.failedToCreateURL) }

        let urlRequest = URLRequest(url: url)

        return URLSession.shared.rx.data(request: urlRequest)
            .map {
                try JSONDecoder().decode(StateResponse.self, from: $0)
            }
            .map { $0.data.map { $0.state } }
    }

    func getCities(of state: String, country: String) -> Observable<[CityName]> {
        guard let url = createURL(host: host,
                                  path: "cities",
                                  key: apiKey,
                                  param: [
                                    "state": state,
                                    "country": country
                                  ])
        else { return Observable.error(APIError.failedToCreateURL) }

        let urlRequest = URLRequest(url: url)

        return URLSession.shared.rx.data(request: urlRequest)
            .map {
                try JSONDecoder().decode(CityResponse.self, from: $0)
            }
            .map { $0.data.map { $0.city } }
    }

    func getNearestCityData() -> Observable<CityData> {
        guard let url = createURL(host: host,
                                  path: "nearest_city",
                                  key: apiKey)
        else { return Observable.error(APIError.failedToCreateURL) }

        let urlRequest = URLRequest(url: url)

        return URLSession.shared.rx.data(request: urlRequest)
            .map {
                try JSONDecoder().decode(CityDataResponse.self, from: $0)
            }
            .map { $0.toCityData() }
    }

    func getCityData(_ city: String, state: String, country: String) -> Observable<CityData> {
        guard let url = createURL(host: host,
                                  path: "city",
                                  key: apiKey,
                                  param: [
                                    "city": city,
                                    "state": state,
                                    "country": country
                                  ])
        else { return Observable.error(APIError.failedToCreateURL) }

        let urlRequest = URLRequest(url: url)

        return URLSession.shared.rx.data(request: urlRequest)
            .map {
                try JSONDecoder().decode(CityDataResponse.self, from: $0)
            }
            .map { $0.toCityData() }
    }

    private func createURL(host: String,
                           path: String,
                           key: String,
                           param: [String: String] = [:]) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = host
        urlComponents.path = "/v2/\(path)"

        let keyQueryItems = URLQueryItem(name: "key", value: key)
        let paramQueryItems: [URLQueryItem] = param.keys
            .map { URLQueryItem(name: $0, value: param[$0]) }

        urlComponents.queryItems = paramQueryItems + [keyQueryItems]

        return urlComponents.url
    }
}

extension CityDataResponse {
    func toCityData() -> CityData {

        return CityData(city: data.city,
                        state: data.state,
                        country: data.country,
                        location: getCityLocation(),
                        weather: getCityWeather(),
                        pollution: getCityPollution())
    }

    private func getCityPollution() -> CityPollution {
        let pollution = data.current.pollution
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        let time = formatter.date(from: pollution.timestamp)

        return CityPollution(timestamp: time,
                             airQualityIndexUS: pollution.airQualityIndexUS,
                             mainPollutantUS: pollution.mainPollutantUS,
                             airQualityIndexChina: pollution.airQualityIndexChina,
                             mainPollutantChina: pollution.mainPollutantChina)
    }

    private func getCityWeather() -> CityWeather {
        let weather = data.current.weather
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions =  [.withInternetDateTime, .withFractionalSeconds]
        let time = formatter.date(from: weather.timestamp)

        return CityWeather(timestamp: time,
                           temperature: weather.temperature,
                           pressure: weather.pressure,
                           humidity: weather.humidity,
                           windSpeed: weather.windSpeed,
                           windDirection: weather.windDirection,
                           icon: weather.iconCode)
    }

    private func getCityLocation() -> CityLocation? {
        let location = data.location
        guard location.coordinates.count >= 2 else { return nil }

        return CityLocation(
            latitude: location.coordinates[0],
            longitude: location.coordinates[1])
    }
}
