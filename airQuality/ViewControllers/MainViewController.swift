//
//  MainViewController.swift
//  airQuality
//
//  Created by Deni Zakya on 18/10/20.
//

import Foundation
import UIKit
import RxSwift
import os.log

final class MainViewController: UIViewController {
    
    @IBOutlet weak var aqiUSLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var weatherIconView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var currentCityContainer: UIView!

    private let disposeBag = DisposeBag()
    private let api = AirVisualApi()
    private let indicator = UIActivityIndicatorView(style: .large)
    private var cityData: CityData?

    override func viewDidLoad() {
        super.viewDidLoad()

        let nearestCityData = api.getNearestCityData()
            .asDriver(onErrorDriveWith: .empty())
            .do { [weak self] _ in
                self?.hideLoadingIndicator()
            } onSubscribed: { [weak self] in
                self?.showLoadingIndicator()
            }
        
        nearestCityData.drive(onNext: { [weak self] data in self?.cityData = data })
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
            .compactMap { URL(string: "https://www.airvisual.com/images/\($0).png") }
            .compactMap { getData(of: $0) }.map { UIImage(data: $0) }
            .drive(weatherIconView.rx.image)
            .disposed(by: disposeBag)
        nearestCityData.map(\.pollution.airQualityIndexUS)
            .compactMap { AirQualityIndexColor(UInt($0))?.getColor() }
            .drive(currentCityContainer.rx.backgroundColor)
            .disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? DetailViewController {
            viewController.cityData = cityData
        }
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

private func getData(of url: URL) -> Data? {
    do {
        return try Data(contentsOf: url)
    } catch {
        os_log(.error, "unable to retrieve data")
        return nil
    }
}
