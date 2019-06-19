//
//  School.swift
//  LaundryView
//
//  Created by Jacob Burroughs on 10/18/17.
//  Copyright © 2017 Jacob Burroughs. All rights reserved.
//

import Foundation

class School: Comparable {
    var id: String
    var name: String
    
    static func <(lhs: School, rhs: School) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func ==(lhs: School, rhs: School) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
