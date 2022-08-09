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
    var dateDone: Date?
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
    
    static func addMachine(_ machine: CurrentMachine) {
        var machines = get() ?? []
        machines.insert(machine, at: 0)
        save(machines)
    }
    
    static func removeMachine(with id: String) {
        if var machines = get(), let index = machines.firstIndex(where: { $0.id == id }) {
            machines.remove(at: index)
            save(machines)
        }
    }
    
    static func getAndFilter() -> [CurrentMachine] {
        let machines = get() ?? []
        let date = Date()
        let filteredMachines = machines.filter({ machine in
            if let dateDone = machine.dateDone {
                let difference = Calendar.current.dateComponents([.hour], from: date, to: dateDone).hour ?? 0
                return difference > -10
            }
            return false
        })
        return filteredMachines
    }
}
