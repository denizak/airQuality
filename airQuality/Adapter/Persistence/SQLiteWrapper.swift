//
//  SQLiteWrapper.swift
//  airQuality
//
//  Created by Deni Zakya on 20/10/20.
//

import Foundation
import SQLite
import os.log

struct SQLiteWrapper {
    static let shared = SQLiteWrapper()

    private let dbConnection: Connection
    private let dbVersion = 1

    init?(inMemory: Bool = false) {
        if inMemory {
            do {
                dbConnection = try Connection(.inMemory)
                try createTable()
            } catch { return nil }
        } else {
            let createTableNeeded = SQLiteWrapper.isDBFileExists() == false
            guard let connection = SQLiteWrapper.openConnection() else { return nil }

            dbConnection = connection

            if createTableNeeded {
                do {
                    try createTable()
                } catch {
                    os_log("\(error.localizedDescription)")
                    return nil
                }
                dbConnection.userVersion = dbVersion
            }
        }
    }

    private static func openConnection() -> Connection? {
        guard let filePath = getDatabasePath() else { return nil }
        do {
            return try Connection(filePath.absoluteString)
        } catch { return nil }
    }

    private static func getDatabasePath() -> URL? {
        guard let filePath = SQLiteWrapper.getDocumentsFolder()?.appendingPathComponent("db")
            else { return nil }

        return filePath
    }

    private static func getDocumentsFolder() -> URL? {
        do {
            return try FileManager.default.url(for: .documentDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: false)
        } catch { return nil }
    }

    private static func isDBFileExists() -> Bool {
        guard let path = getDatabasePath() else { return false }
        return FileManager.default.fileExists(atPath: path.path)
    }


    private func createTable() throws {
        try createCityDataTable()
        try createCitySelectionTable()
    }

    private func createCityDataTable() throws {
        let characteristics = Table("city_data")

        let city = Expression<String>("city")
        let state = Expression<String>("state")
        let country = Expression<String>("country")
        let temperature = Expression<Int64>("temperature")
        let pressure = Expression<Int64>("pressure")
        let humidity = Expression<Int64>("humidity")
        let windSpeed = Expression<Double>("wind_speed")
        let windDirection = Expression<Int64>("wind_direction")
        let icon = Expression<String>("icon")
        let airQualityIndex = Expression<Int64>("aqi")

        try dbConnection.run(characteristics.create { table in
            table.column(city, unique: true)
            table.column(state)
            table.column(country)
            table.column(temperature)
            table.column(pressure)
            table.column(humidity)
            table.column(windSpeed)
            table.column(windDirection)
            table.column(icon)
            table.column(airQualityIndex)
        })
    }

    private func createCitySelectionTable() throws {
        let characteristics = Table("city_selection")

        let city = Expression<String>("city")
        let state = Expression<String>("state")
        let country = Expression<String>("country")

        try dbConnection.run(characteristics.create { table in
            table.column(city, unique: true)
            table.column(state)
            table.column(country)
        })
    }

    func delete(_ action: Delete) throws {
        try dbConnection.run(action)
    }

    func insert(row: Insert) throws -> Int64 {
        return try dbConnection.run(row)
    }

    func getRows(table: Table) throws -> [Row] {
        return try dbConnection.prepare(table).map { $0 }
    }

    func getFirstRow(table: Table) throws -> Row? {
        return try dbConnection.pluck(table)
    }

    func destroyDatabase() {
        guard let path = SQLiteWrapper.getDatabasePath() else { return }
        try? FileManager.default.removeItem(at: path)
    }
}

extension Connection {
    public var userVersion: Int {
        get { return Int(try! scalar("PRAGMA user_version") as! Int64)}
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}
