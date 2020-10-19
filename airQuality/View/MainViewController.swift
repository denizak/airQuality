//
//  MainViewController.swift
//  airQuality
//
//  Created by Deni Zakya on 18/10/20.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import RxCocoa

import os.log

struct CityItemSelection {
    let cityName: String
    let stateName: String
    let countryName: String
}

final class MainViewController: UIViewController {
    
    @IBOutlet weak var cityList: UITableView!
    @IBOutlet weak var aqiUSLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var weatherIconView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var currentCityContainer: UIView!

    private let citySelectionDisposable = SerialDisposable()
    private let disposeBag = DisposeBag()
    private let api = AirVisualApi()
    private let indicator = UIActivityIndicatorView(style: .large)
    private var nearestCityData: CityData?
    private var selectedCityData: CityData?
    private var citySelectionsData = PublishRelay<[CityData]>()

    private var citySelections: [CityItemSelection] = []

    deinit {
        citySelectionDisposable.dispose()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        cityList.tableFooterView = createAddCityButton()

        setupNearestCity()
        setupSelectedCity()

        loadSelectedCity()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? DetailViewController,
           segue.identifier == "showDetail" {
            viewController.cityData = selectedCityData
        } else if let viewController = segue.destination as? DetailViewController {
            viewController.cityData = nearestCityData
        } else if let navigationController = segue.destination as? UINavigationController,
                  let viewController = navigationController.viewControllers.first as? CityPickerViewController {
            viewController.delegate = self
        }
    }

    @objc
    private func showAddCity() {
        performSegue(withIdentifier: "showCityPicker", sender: self)
    }

    private func setupNearestCity() {
        let nearestCityData = api.getNearestCityData()
            .asDriver(onErrorDriveWith: .empty())
            .do { [weak self] _ in
                self?.hideLoadingIndicator()
            } onSubscribed: { [weak self] in
                self?.showLoadingIndicator()
            }

        nearestCityData.drive(onNext: { [weak self] data in self?.nearestCityData = data })
            .disposed(by: disposeBag)
        nearestCityData.map { $0.city }
            .drive(cityLabel.rx.text)
            .disposed(by: disposeBag)
        nearestCityData.map { "\($0.state), \($0.country)" }
            .drive(originLabel.rx.text)
            .disposed(by: disposeBag)
        nearestCityData.map(\.pollution.airQualityIndexUS).map { "\($0)" }
            .drive(aqiUSLabel.rx.text)
            .disposed(by: disposeBag)
        nearestCityData.map(\.weather.temperature).map { "\($0)°C" }
            .drive(temperatureLabel.rx.text)
            .disposed(by: disposeBag)
        nearestCityData.map(\.weather.icon)
            .drive(onNext: { [weak self] index in
                self?.weatherIconView.loadWeatherIcon(index: index)
            })
            .disposed(by: disposeBag)
        nearestCityData.map(\.pollution.airQualityIndexUS)
            .compactMap { AirQualityIndexColor(UInt($0))?.getColor() }
            .drive(currentCityContainer.rx.backgroundColor)
            .disposed(by: disposeBag)
    }

    private func addCity(_ citySelection: CityItemSelection) {
        citySelections.append(citySelection)
        loadSelectedCity()
    }

    private func createAddCityButton() -> UIView {
        let width = cityList.frame.width
        let view = UIView(frame: .init(x: 0, y: 0, width: width, height: 50))
        let button = UIButton(frame: .init(x: 0, y: 0, width: width, height: 50))
        button.addTarget(self, action: #selector(showAddCity), for: .touchUpInside)
        button.setTitle("Add City", for: .normal)
        button.backgroundColor = .orange

        view.addSubview(button)
        return view
    }

    private func loadSelectedCity() {
        citySelectionDisposable.disposable = Observable.zip(
            citySelections.map { citySelection in
                api.getCityData(citySelection.cityName,
                                state: citySelection.stateName,
                                country: citySelection.countryName)
            }
        )
        .bind(to: citySelectionsData)
    }

    private func setupSelectedCity() {
        citySelectionsData
            .bind(to: cityList.rx.items(cellIdentifier: "cell")) { _, model, cell in
                guard let cell = cell as? CityInfoCell else { fatalError() }

                cell.setup(data: model)
            }.disposed(by: disposeBag)
        cityList.rx.modelSelected(CityData.self)
            .subscribe(onNext: { [unowned self] cityData in
                self.selectedCityData = cityData
                self.performSegue(withIdentifier: "showDetail", sender: self)
            }).disposed(by: disposeBag)
    }

    private func showLoadingIndicator() {
        indicator.center = view.center
        indicator.startAnimating()
        view.addSubview(indicator)
    }

    private func hideLoadingIndicator() {
        indicator.removeFromSuperview()
    }
}

extension MainViewController: SelectedCity {
    func selectCity(city: String, state: String, country: String) {
        os_log("\(city) \(state) \(country)")
        let citySelection = CityItemSelection(cityName: city,
                                              stateName: state,
                                              countryName: country)
        addCity(citySelection)
    }
}
