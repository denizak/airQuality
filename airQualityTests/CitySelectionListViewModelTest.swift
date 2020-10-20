//
//  CitySelectionListViewModelTest.swift
//  airQualityTests
//
//  Created by Deni Zakya on 20/10/20.
//

import XCTest
import RxSwift

@testable import airQuality

final class CitySelectionListViewModelTest: XCTestCase {

    let citySelectionStore = CitySelectionStorage(inMemory: true)
    let cityDataStore = CityDataStorage(inMemory: true)

    func testFetch() {
        _ = citySelectionStore.insert(city: "City", state: "State", country: "Country")
        let viewModel = CitySelectionListViewModel(api: ApiStub(),
                                                   citySelectionStore: citySelectionStore,
                                                   cityDataStore: CityDataStorage(inMemory: true))
        var cityData = [CityData]()
        let disposable = viewModel.cityData.drive { cityData = $0 }
        defer { disposable.dispose() }

        viewModel.fetchSelectedCityData()

        XCTAssertEqual(cityData.count, 1)
    }

    func testFetchOffline() {
        _ = citySelectionStore.insert(city: "City", state: "State", country: "Country")
        _ = cityDataStore.insert(cityData: cityDataSample())
        let viewModel = CitySelectionListViewModel(api: ApiOfflineStub(),
                                                   citySelectionStore: citySelectionStore,
                                                   cityDataStore: cityDataStore)
        var cityData = [CityData]()
        let disposable = viewModel.cityData.drive { cityData = $0 }
        defer { disposable.dispose() }

        viewModel.fetchSelectedCityData()

        XCTAssertEqual(cityData.count, 1)
    }
}

private func cityDataSample() -> CityData {
    CityData(city: "City",
             state: "State",
             country: "Country",
             location: nil,
             weather: .init(timestamp: nil,
                            temperature: 10,
                            pressure: 10,
                            humidity: 10,
                            windSpeed: 10,
                            windDirection: 10,
                            icon: "icon"),
             pollution: .init(timestamp: nil,
                              airQualityIndexUS: 10,
                              mainPollutantUS: "",
                              airQualityIndexChina: 10,
                              mainPollutantChina: ""))
}

final class ApiStub: CityDataApi {
    func getCountries() -> Observable<[CountryName]> {
        .empty()
    }

    func getStates(of country: String) -> Observable<[StateName]> {
        .empty()
    }

    func getCities(of state: String, country: String) -> Observable<[CityName]> {
        .empty()
    }

    func getNearestCityData() -> Observable<CityData> {
        .empty()
    }

    func getCityData(_ city: String, state: String, country: String) -> Observable<CityData> {
        .just(cityDataSample())
    }
}

final class ApiOfflineStub: CityDataApi {
    func getCountries() -> Observable<[CountryName]> {
        .empty()
    }

    func getStates(of country: String) -> Observable<[StateName]> {
        .empty()
    }

    func getCities(of state: String, country: String) -> Observable<[CityName]> {
        .empty()
    }

    func getNearestCityData() -> Observable<CityData> {
        .empty()
    }

    func getCityData(_ city: String, state: String, country: String) -> Observable<CityData> {
        .empty()
    }
}
