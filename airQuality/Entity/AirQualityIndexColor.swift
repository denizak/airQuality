//
//  AirQualityIndexCOlor.swift
//  airQuality
//
//  Created by Deni Zakya on 18/10/20.
//

import Foundation
import UIKit

enum AirQualityIndexColor: Equatable {
    case good
    case moderate
    case unhealthyForSensitive
    case unhealthy
    case veryUnhealthy
    case hazardous

    init?(_ value: UInt) {
        switch value {
        case 0...50: self = .good
        case 51...100: self = .moderate
        case 101...150: self = .unhealthyForSensitive
        case 151...200: self = .unhealthy
        case 201...300: self = .veryUnhealthy
        default: self = .hazardous
        }
    }

    func getColor() -> UIColor {
        switch self {
        case .good: return .green
        case .moderate: return .yellow
        case .unhealthyForSensitive: return .orange
        case .unhealthy: return .red
        case .veryUnhealthy: return .purple
        case .hazardous: return UIColor(red: 115.0/255.0, green: 20.0/255.0, blue: 37.0/255.0, alpha: 1.0)
        }
    }
}
