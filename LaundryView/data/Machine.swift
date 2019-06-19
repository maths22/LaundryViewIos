//
//  Machine.swift
//  LaundryView
//
//  Created by Jacob Burroughs on 10/18/17.
//  Copyright © 2017 Jacob Burroughs. All rights reserved.
//

import Foundation



enum MachineType {
    case washer
    case dryer
}

enum Status: String {
    case available
    case inUse
    case done
    case outOfService
    case unknown
}

class Machine: Comparable {
    static func <(lhs: Machine, rhs: Machine) -> Bool {
        return lhs.number < rhs.number
    }
    
    static func ==(lhs: Machine, rhs: Machine) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String
    var number: String
    var status: Status
    var type: MachineType
    var timeRemaining: Int?
    
    init(id: String, number: String, status: Status, type: MachineType, timeRemaining: Int?) {
        self.id = id
        self.number = number
        self.status = status
        self.type = type
        self.timeRemaining = timeRemaining
    }

}
