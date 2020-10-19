//
//  CityInfoCell.swift
//  airQuality
//
//  Created by Deni Zakya on 19/10/20.
//

import Foundation
import UIKit

final class CityInfoCell: UITableViewCell {
    static let identifier = "cell"

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var originLabel: UILabel!
    @IBOutlet weak var weatherIconView: UIImageView!
    @IBOutlet weak var aqiUSLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
    }

    func setup(data: CityData) {
        cityLabel.text = data.city
        originLabel.text = "\(data.state), \(data.country)"
        aqiUSLabel.text = "\(data.pollution.airQualityIndexUS)"
        temperatureLabel.text = "\(data.weather.temperature)°C"
        weatherIconView.loadWeatherIcon(index: data.weather.icon)

        containerView.backgroundColor = AirQualityIndexColor(UInt(data.pollution.airQualityIndexUS))?
            .getColor()
    }
}
