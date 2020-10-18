//
//  CountryResponse.swift
//  airQuality
//
//  Created by Deni Zakya on 18/10/20.
//

import Foundation

struct CountryResponse: Decodable {
    let status: String
    let data: [CountryItemResponse]
}

struct CountryItemResponse: Decodable {
    let country: String
}
