//
//  LaundryViewApiService.swift
//  LaundryView
//
//  Created by Jacob Burroughs on 10/18/17.
//  Copyright © 2017 Jacob Burroughs. All rights reserved.
//

import Foundation
import Alamofire

var machines: [MachineType: [Machine]]?

class LVAPIService {
    
    static let endpoint = "https://lvapi.maths22.com/lv_api"
    
    init() {
    }
    
    fileprivate func convertMachine(_ machine: [String: Any], _ type: MachineType) -> Machine {
        var timeRemaining : Int? = machine["timeRemaining"] == nil ? nil : Int(truncating: machine["timeRemaining"] as! NSNumber)
        if(timeRemaining != nil && timeRemaining! < 0) {
            timeRemaining = nil
        }
        var status : Status
        switch machine["status"] as! String {
        case "AVAILBLE":
            status = Status.available
        case "IN_USE":
            status = Status.inUse
        case "DONE":
            status = Status.done
        case "OUT_OF_SERVICE":
            status = Status.outOfService
        case "UNKNOWN":
            status = Status.unknown
        default:
            status = Status.unknown
        }
        return Machine(id: (machine["id"] as! String), number: (machine["number"] as! String), status: status, type: type, timeRemaining: timeRemaining)
    }
    
    func reloadMachines() {
        if (UserDefaults.standard.string(forKey: "roomId") != nil) {
            let room = LaundryRoom(
                id: UserDefaults.standard.string(forKey: "roomId")!,
                name: UserDefaults.standard.string(forKey: "roomName")!
            )
            machineStatus(laundryRoom: room, completion: { theseMachines in
                machines = theseMachines
                NotificationCenter.default.post(name: .machineDataReloaded, object: nil)
            })
        }
    }
    
    func machineStatus(laundryRoom: LaundryRoom, completion: @escaping ([MachineType : [Machine]]) -> Void) {
        Alamofire.request(LVAPIService.endpoint, method: .post, parameters: ["method": "machineStatus", "args": ["roomId": laundryRoom.id]], encoding: JSONEncoding.default).responseJSON { response in
            if let json = response.result.value {
                let response = json as! [String: [[String: Any]]]
                let dryers = response["dryers"]!.map({ (machine) -> Machine in
                    return self.convertMachine(machine, MachineType.dryer)
                })
                let washers = response["washers"]!.map({ (machine) -> Machine in
                    return self.convertMachine(machine, MachineType.washer)
                })
                let machines = [MachineType.dryer: dryers, MachineType.washer: washers]
                completion(machines);
            }
        }
    }
    
    func findLaundryRooms(school: School, completion: @escaping ([LaundryRoom]) -> Void) {
        Alamofire.request(LVAPIService.endpoint, method: .post, parameters: ["method": "findLaundryRooms", "args": ["schoolId": school.id]], encoding: JSONEncoding.default).responseJSON { response in
            if let json = response.result.value {
                let response = json as! [[String: Any]]
                completion(response.map({ (room) -> LaundryRoom in
                    return LaundryRoom(id: (room["id"] as! String), name: (room["name"] as! String))
                }))
            }
        }
        
    }
    
    func findSchools(name: String, completion: @escaping ([School]) -> Void) {
        Alamofire.request(LVAPIService.endpoint, method: .post, parameters: ["method": "findSchools", "args": ["name": name]], encoding: JSONEncoding.default).responseJSON { response in
            if let json = response.result.value {
                let response = json as! [[String: Any]]
                completion(response.map({ (school) -> School in
                    return School(id: (school["id"] as! String), name: (school["name"] as! String))
                }))
            }
        }
    }
    
    func registerNotification(machineId: String, requesterId: String) {
        Alamofire.request(LVAPIService.endpoint, method: .post, parameters: ["method": "registerMachine", "args": ["machineId": machineId, "requesterId": requesterId]], encoding: JSONEncoding.default)
    }
    
    func unregisterNotification(machineId: String, requesterId: String) {
        Alamofire.request(LVAPIService.endpoint, method: .post, parameters: ["method": "unregisterMachine", "args": ["machineId": machineId, "requesterId": requesterId]], encoding: JSONEncoding.default)
    }
    
    

}
