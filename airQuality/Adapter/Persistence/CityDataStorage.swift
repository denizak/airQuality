//
//  CityDataStorage.swift
//  airQuality
//
//  Created by Deni Zakya on 20/10/20.
//

import Foundation
import SQLite
import os.log

struct CityDataStorage {
    private let storage: SQLiteWrapper?
    private let cityDataTable = Table("city_data")

    private let cityColumn = Expression<String>("city")
    private let stateColumn = Expression<String>("state")
    private let countryColumn = Expression<String>("country")
    private let temperatureColumn = Expression<Int64>("temperature")
    private let pressureColumn = Expression<Int64>("pressure")
    private let humidityColumn = Expression<Int64>("humidity")
    private let windSpeedColumn = Expression<Double>("wind_speed")
    private let windDirectionColumn = Expression<Int64>("wind_direction")
    private let iconColumn = Expression<String>("icon")
    private let airQualityIndexColumn = Expression<Int64>("aqi")

    init(inMemory: Bool = false) {
        storage = inMemory ? SQLiteWrapper(inMemory: true) : SQLiteWrapper.shared
    }

    func insert(cityData: CityData) -> Int64 {
        guard let storage = storage else { return 0 }

        let insertStatement = cityDataTable.insert(
            cityColumn <- cityData.city,
            stateColumn <- cityData.state,
            countryColumn <- cityData.country,
            temperatureColumn <- Int64(cityData.weather.temperature),
            pressureColumn <- Int64(cityData.weather.pressure),
            humidityColumn <- Int64(cityData.weather.humidity),
            windSpeedColumn <- cityData.weather.windSpeed,
            windDirectionColumn <- Int64(cityData.weather.windDirection),
            iconColumn <- cityData.weather.icon,
            airQualityIndexColumn <- Int64(cityData.pollution.airQualityIndexUS)
        )
        do {
            return try storage.insert(row: insertStatement)
        } catch {
            os_log("\(error.localizedDescription)")
        }

        return 0
    }

    func get(city: String, state: String, country: String) -> CityData? {
        guard let storage = storage else { return nil }
        do {
            let rows = try storage.getRows(table: cityDataTable
                                            .where(cityColumn == city &&
                                                    stateColumn == state &&
                                                    countryColumn == country))

            guard let item = rows.first else { return nil }

            return CityData(city: item[cityColumn],
                            state: item[stateColumn],
                            country: item[countryColumn],
                            location: nil,
                            weather: .init(timestamp: nil,
                                           temperature: Int(item[temperatureColumn]),
                                           pressure: Int(item[pressureColumn]),
                                           humidity: Int(item[humidityColumn]),
                                           windSpeed: item[windSpeedColumn],
                                           windDirection: Int(item[windDirectionColumn]),
                                           icon: item[iconColumn]),
                            pollution: .init(timestamp: nil,
                                             airQualityIndexUS: Int(item[airQualityIndexColumn]),
                                             mainPollutantUS: "",
                                             airQualityIndexChina: 0,
                                             mainPollutantChina: ""))
        } catch { return nil }
    }
}
