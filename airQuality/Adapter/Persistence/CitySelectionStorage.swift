//
//  CitySelectionStorage.swift
//  airQuality
//
//  Created by Deni Zakya on 20/10/20.
//

import Foundation
import SQLite
import os.log

struct CitySelectionStorage {
    private let storage: SQLiteWrapper?
    private let citySelectionTable = Table("city_selection")

    private let cityColumn = Expression<String>("city")
    private let stateColumn = Expression<String>("state")
    private let countryColumn = Expression<String>("country")

    init(inMemory: Bool = false) {
        storage = inMemory ? SQLiteWrapper(inMemory: true) : SQLiteWrapper.shared
    }

    func insert(city: String, state: String, country: String) -> Int64 {
        guard let storage = storage else { return 0 }

        let insertStatement = citySelectionTable.insert(
            cityColumn <- city,
            stateColumn <- state,
            countryColumn <- country
        )
        do {
            return try storage.insert(row: insertStatement)
        } catch {
            os_log("\(error.localizedDescription)")
        }

        return 0
    }

    func get() -> [CityItemSelection] {
        guard let storage = storage else { return [] }
        do {
            let rows = try storage.getRows(table: citySelectionTable)

            return rows.map { CityItemSelection(cityName: $0[cityColumn],
                                         stateName: $0[stateColumn],
                                         countryName: $0[countryColumn]) }
        } catch { return [] }
    }
}
