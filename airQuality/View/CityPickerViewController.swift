//
//  CityPickerViewController.swift
//  airQuality
//
//  Created by Deni Zakya on 19/10/20.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay

protocol SelectedCity: class {
    func selectCity(city: String, state: String, country: String)
}

final class CityPickerViewController: UIViewController {

    @IBOutlet weak var countryTableView: UITableView!
    @IBOutlet weak var stateTableView: UITableView!
    @IBOutlet weak var cityTableView: UITableView!

    weak var delegate: SelectedCity?

    private let api = AirVisualApi()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCountries().flatMap { [unowned self] countryName in
            self.loadState(country: countryName).map { (countryName, $0) }
        }.flatMap { [unowned self] (countryName, stateName) in
            self.loadCity(country: countryName, state: stateName)
                .map { (countryName, stateName, $0) }
        }.subscribe { [unowned self] (countryName, stateName, cityName) in
            self.delegate?.selectCity(city: cityName, state: stateName, country: countryName)
            self.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }

    private func loadCountries() -> Observable<String> {
        let relay = PublishRelay<String>()
        api.getCountries()
            .bind(to: countryTableView.rx.items(cellIdentifier: "cell")) { _, countryName, cell in
                cell.textLabel?.text = countryName
            }.disposed(by: disposeBag)
        countryTableView.rx.modelSelected(String.self)
            .subscribe(onNext: { countryName in
                relay.accept(countryName)
            }).disposed(by: disposeBag)

        return relay.asObservable()
    }

    private func loadState(country: String) -> Observable<String> {
        stateTableView.isHidden = false

        let relay = PublishRelay<String>()

        api.getStates(of: country)
            .bind(to: stateTableView.rx.items(cellIdentifier: "cell")) { _, stateName, cell in
                cell.textLabel?.text = stateName
            }.disposed(by: disposeBag)
        stateTableView.rx.modelSelected(String.self)
            .subscribe(onNext: { stateName in
                relay.accept(stateName)
            }).disposed(by: disposeBag)

        return relay.asObservable()
    }

    private func loadCity(country: String, state: String) -> Observable<String> {
        cityTableView.isHidden = false

        let relay = PublishRelay<String>()

        api.getCities(of: state, country: country)
            .catchAndReturn([])
            .bind(to: cityTableView.rx.items(cellIdentifier: "cell")) { _, cityName, cell in
                cell.textLabel?.text = cityName
            }.disposed(by: disposeBag)
        cityTableView.rx.modelSelected(String.self)
            .subscribe(onNext: { cityName in
                relay.accept(cityName)
            }).disposed(by: disposeBag)

        return relay.asObservable()
    }
}
