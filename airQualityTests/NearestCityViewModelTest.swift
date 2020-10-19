//
//  NearestCityViewModelTest.swift
//  airQualityTests
//
//  Created by Deni Zakya on 19/10/20.
//

import XCTest
import RxSwift

@testable import airQuality

final class NearestCityViewModelTest: XCTestCase {

    private let disposeBag = DisposeBag()

    func testGetData() {
        let viewModel = NearestCityViewModel(api: CityDataApiStub())

        var actualCity = ""
        var actualOrigin = ""
        var actualAirQualityIndex = ""
        var actualTemperature = ""
        var actualWeatherIcon = ""
        var actualAirQualityColor = UIColor.white
        viewModel.cityName.drive { actualCity = $0 }.disposed(by: disposeBag)
        viewModel.originName.drive { actualOrigin = $0 }.disposed(by: disposeBag)
        viewModel.airQualityIndex.drive { actualAirQualityIndex = $0 }
            .disposed(by: disposeBag)
        viewModel.temperature.drive { actualTemperature = $0 }.disposed(by: disposeBag)
        viewModel.weatherIcon.drive { actualWeatherIcon = $0 }.disposed(by: disposeBag)
        viewModel.airQualityColor.drive { actualAirQualityColor = $0 }.disposed(by: disposeBag)

        viewModel.getData()

        XCTAssertEqual(actualCity, "Jakarta")
        XCTAssertEqual(actualOrigin, "Jakarta, Indonesia")
        XCTAssertEqual(actualAirQualityIndex, "10")
        XCTAssertEqual(actualTemperature, "100°C")
        XCTAssertEqual(actualWeatherIcon, "10d")
        XCTAssertEqual(actualAirQualityColor, .green)
    }

}

final class CityDataApiStub: CityDataApi {
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
        .just(
            CityData(city: "Jakarta",
                     state: "Jakarta",
                     country: "Indonesia",
                     location: nil,
                     weather: .init(timestamp: .init(),
                                    temperature: 100,
                                    pressure: 10,
                                    humidity: 1,
                                    windSpeed: 1,
                                    windDirection: 1,
                                    icon: "10d"),
                     pollution: .init(timestamp: .init(),
                                      airQualityIndexUS: 10,
                                      mainPollutantUS: "pm",
                                      airQualityIndexChina: 10,
                                      mainPollutantChina: "pm"))
        )
    }

    func getCityData(_ city: String, state: String, country: String) -> Observable<CityData> {
        .empty()
    }


}
