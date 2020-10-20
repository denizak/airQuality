//
//  StateResponse.swift
//  airQuality
//
//  Created by Deni Zakya on 18/10/20.
//

import Foundation

struct StateResponse: Decodable {
    let status: String
    let data: [StateItemResponse]
}

struct StateItemResponse: Decodable {
    let state: String
}
