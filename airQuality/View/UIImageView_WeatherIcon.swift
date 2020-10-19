//
//  UIImageView_WeatherIcon.swift
//  airQuality
//
//  Created by Deni Zakya on 19/10/20.
//

import Foundation
import UIKit
import os.log

extension UIImageView {
    func loadWeatherIcon(index: String) {
        DispatchQueue.global(qos: .default)
            .async {
                let urlString = "https://www.airvisual.com/images/\(index).png"
                if let url = URL(string: urlString) {
                    do {
                        let data = try Data(contentsOf: url)
                        let image = UIImage(data: data)

                        DispatchQueue.main.async {
                            self.image = image
                        }
                    } catch {
                        os_log(.error, "unable to retrieve icon data")
                    }
                }
            }
    }
}
