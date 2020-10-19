//
//  NearestCityViewModel.swift
//  airQuality
//
//  Created by Deni Zakya on 19/10/20.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class NearestCityViewModel {

    private let serialDisposable = SerialDisposable()

    private(set) var cityData: CityData?

    private let cityNameRelay = BehaviorRelay<String>(value: "")
    var cityName: Driver<String> {
        cityNameRelay.asDriver()
    }

    private let originNameRelay = BehaviorRelay<String>(value: "")
    var originName: Driver<String> {
        originNameRelay.asDriver()
    }

    private let airQualityIndexRelay = BehaviorRelay<Int>(value: 0)
    var airQualityIndex: Driver<String> {
        airQualityIndexRelay.asDriver().map { "\($0)" }
    }

    private let temperatureRelay = BehaviorRelay<Int>(value: 0)
    var temperature: Driver<String> {
        temperatureRelay.asDriver().map { "\($0)°C" }
    }

    private let weatherIconRelay = BehaviorRelay<String>(value: "")
    var weatherIcon: Driver<String> {
        weatherIconRelay.asDriver()
    }

    var airQualityColor: Driver<UIColor> {
        airQualityIndexRelay
            .compactMap { AirQualityIndexColor(UInt($0))?.getColor() }
            .asDriver(onErrorJustReturn: .white)
    }

    private let hideLoadingRelay = PublishRelay<Void>()
    private let showLoadingRelay = PublishRelay<Void>()
    var hideLoadingIndicator: Driver<Void> {
        hideLoadingRelay.asDriver(onErrorJustReturn: ())
    }
    var showLoadingIndicator: Driver<Void> {
        showLoadingRelay.asDriver(onErrorJustReturn: ())
    }

    private let cityDataApi: CityDataApi

    init(api: CityDataApi = AirVisualApi()) {
        self.cityDataApi = api
    }

    func getData() {
        serialDisposable.disposable = cityDataApi.getNearestCityData()
            .do { [weak self] _ in
                self?.hideLoadingRelay.accept(())
            } onSubscribed: { [weak self] in
                self?.showLoadingRelay.accept(())
            }
            .subscribe(onNext: { [weak self] cityData in
                self?.cityData = cityData
                self?.cityNameRelay.accept(cityData.city)
                self?.originNameRelay.accept("\(cityData.state), \(cityData.country)")
                self?.airQualityIndexRelay.accept(cityData.pollution.airQualityIndexUS)
                self?.temperatureRelay.accept(cityData.weather.temperature)
                self?.weatherIconRelay.accept(cityData.weather.icon)
            })
    }
}
