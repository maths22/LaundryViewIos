//
//  LaundryRoom.swift
//  LaundryView
//
//  Created by Jacob Burroughs on 10/18/17.
//  Copyright © 2017 Jacob Burroughs. All rights reserved.
//

import Foundation

class LaundryRoom {
    var id: String
    var name: String
    
    static func <(lhs: LaundryRoom, rhs: LaundryRoom) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func ==(lhs: LaundryRoom, rhs: LaundryRoom) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
