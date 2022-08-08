//
//  CurrentMachine.swift
//  LaundryView
//
//  Created by Oliver Elliott on 8/7/22.
//  Copyright © 2022 Jacob Burroughs. All rights reserved.
//

import Foundation

struct CurrentMachine: Codable {
    var id: String
    var number: String
    var type: MachineType
    var startDate: Date
    var dateDone: Date
}

struct CurrentMachineCache {
    static let key = "CurrentMachines"
    static func save(_ value: [CurrentMachine]!) {
         UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey: key)
    }
    static func get() -> [CurrentMachine]? {
        var userData: [CurrentMachine]?
        if let data = UserDefaults.standard.value(forKey: key) as? Data {
            do {
                userData = try PropertyListDecoder().decode([CurrentMachine].self, from: data)
            } catch {
                print("Error Getting Data")
            }
            return userData
        } else {
            return userData
        }
    }
    static func remove() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
