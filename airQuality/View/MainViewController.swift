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

final class MainViewController: UIViewController {
    
    @IBOutlet weak var cityList: UITableView!
    @IBOutlet weak var aqiUSLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var weatherIconView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var currentCityContainer: UIView!

    private let disposeBag = DisposeBag()
    private let citySelectionListViewModel = CitySelectionListViewModel()
    private let nearestViewModel = NearestCityViewModel()
    private let indicator = UIActivityIndicatorView(style: .large)
    private var selectedCityData: CityData?

    override func viewDidLoad() {
        super.viewDidLoad()

        cityList.tableFooterView = createAddCityButton()

        setupNearestCity()
        setupSelectedCity()

        citySelectionListViewModel.fetchSelectedCityData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let addCityButton = cityList.tableFooterView?.subviews.first
        addCityButton?.frame = CGRect(x: 0, y: 0, width: cityList.frame.width, height: 50)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? DetailViewController,
           segue.identifier == "showDetail" {
            viewController.cityData = selectedCityData
        } else if let viewController = segue.destination as? DetailViewController {
            viewController.cityData = nearestViewModel.cityData
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
        nearestViewModel.cityName
            .drive(cityLabel.rx.text)
            .disposed(by: disposeBag)
        nearestViewModel.originName
            .drive(originLabel.rx.text)
            .disposed(by: disposeBag)
        nearestViewModel.airQualityIndex
            .drive(aqiUSLabel.rx.text)
            .disposed(by: disposeBag)
        nearestViewModel.temperature
            .drive(temperatureLabel.rx.text)
            .disposed(by: disposeBag)
        nearestViewModel.weatherIcon
            .drive { [weak self] icon in
                self?.weatherIconView.loadWeatherIcon(index: icon)
            }.disposed(by: disposeBag)
        nearestViewModel.airQualityColor
            .drive(currentCityContainer.rx.backgroundColor)
            .disposed(by: disposeBag)
        nearestViewModel.hideLoadingIndicator
            .drive { [weak self] _ in
                self?.hideLoadingIndicator()
            }
            .disposed(by: disposeBag)
        nearestViewModel.showLoadingIndicator
            .drive { [weak self] _ in
                self?.showLoadingIndicator()
            }
            .disposed(by: disposeBag)

        nearestViewModel.getData()
    }

    private func addCity(_ citySelection: CityItemSelection) {
        citySelectionListViewModel.addCity(citySelection)
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

    private func setupSelectedCity() {
        citySelectionListViewModel.cityData
            .drive(cityList.rx.items(cellIdentifier: "cell")) { _, model, cell in
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
