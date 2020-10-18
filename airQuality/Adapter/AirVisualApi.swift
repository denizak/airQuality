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

final class AirVisualApi {

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
