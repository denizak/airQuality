//
//  CitySelectionListViewModel.swift
//  airQuality
//
//  Created by Deni Zakya on 20/10/20.
//

import Foundation
import RxSwift
import RxCocoa

final class CitySelectionListViewModel {

    private let api: CityDataApi
    private let citySelectionStore: CitySelectionStorage
    private let cityDataStore: CityDataStorage

    private let cityDataRelay = BehaviorRelay<[CityData]>(value: [])
    var cityData: Driver<[CityData]> {
        cityDataRelay.asDriver()
    }

    private let serialDisposable = SerialDisposable()

    init(api: CityDataApi = AirVisualApi(),
         citySelectionStore: CitySelectionStorage = CitySelectionStorage(),
         cityDataStore: CityDataStorage = CityDataStorage()) {
        self.api = api
        self.citySelectionStore = citySelectionStore
        self.cityDataStore = cityDataStore
    }

    func fetchSelectedCityData() {
        fetchFromLocal()
        fetchFromRemote()
    }

    func addCity(_ citySelection: CityItemSelection) {
        _ = citySelectionStore.insert(city: citySelection.cityName,
                                      state: citySelection.stateName,
                                      country: citySelection.countryName)
        fetchSelectedCityData()
    }

    private func fetchFromLocal() {
        let items = citySelectionStore.get()
            .compactMap {
                cityDataStore.get(city: $0.cityName,
                                  state: $0.stateName,
                                  country: $0.countryName)
            }
        cityDataRelay.accept(items)
    }

    private func fetchFromRemote() {
        serialDisposable.disposable = Observable.zip(
            citySelectionStore.get()
                .map { citySelection in
                    api.getCityData(citySelection.cityName,
                                    state: citySelection.stateName,
                                    country: citySelection.countryName)
                }
        )
        .catch { _ in .never() }
        .do(onNext: { items in
            items.forEach { [weak self] item in
                _ = self?.cityDataStore.insert(cityData: item)
            }
        })
        .bind(to: cityDataRelay)
    }

}
