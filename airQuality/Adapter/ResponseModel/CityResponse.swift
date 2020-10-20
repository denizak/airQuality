//
//  CityResponse.swift
//  airQuality
//
//  Created by Deni Zakya on 18/10/20.
//

import Foundation

struct CityResponse: Decodable {
    let status: String
    let data: [CityItemResponse]
}

struct CityItemResponse: Decodable {
    let city: String
}
