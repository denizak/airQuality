//
//  DetailViewController.swift
//  airQuality
//
//  Created by Deni Zakya on 19/10/20.
//

import Foundation
import UIKit
import os.log

final class DetailViewController: UIViewController {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var aqiUSLabel: UILabel!
    @IBOutlet weak var weatherIconView: UIImageView!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var temperatureValueLabel: UILabel!
    @IBOutlet weak var pressureValueLabel: UILabel!
    @IBOutlet weak var humidityValueLabel: UILabel!
    @IBOutlet weak var windSpeedValueLabel: UILabel!
    @IBOutlet weak var windDirectionValueLabel: UILabel!

    var cityData: CityData?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let cityData = cityData else { return }

        cityLabel.text = cityData.city
        aqiUSLabel.text = "\(cityData.pollution.airQualityIndexUS)"
        originLabel.text = "\(cityData.state), \(cityData.country)"
        temperatureValueLabel.text = "\(cityData.weather.temperature)°C"
        pressureValueLabel.text = "\(cityData.weather.pressure) hPa"
        humidityValueLabel.text = "\(cityData.weather.humidity) %"
        windSpeedValueLabel.text = "\(cityData.weather.windSpeed) m/s"
        windDirectionValueLabel.text = "\(cityData.weather.windDirection)"

        loadWeatherIcon(iconName: cityData.weather.icon)
    }

    private func loadWeatherIcon(iconName: String) {
        DispatchQueue.global(qos: .default)
            .async {
                let urlString = "https://www.airvisual.com/images/\(iconName).png"
                if let url = URL(string: urlString) {
                    do {
                        let data = try Data(contentsOf: url)
                        let image = UIImage(data: data)

                        DispatchQueue.main.async {
                            self.weatherIconView.image = image
                        }
                    } catch {
                        os_log(.error, "unable to retrieve icon data")
                    }
                }
            }
    }
}
