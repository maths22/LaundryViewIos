//
//  LaundryRoomTableViewController.swift
//  LaundryView
//
//  Created by Jacob Burroughs on 10/18/17.
//  Copyright © 2017 Jacob Burroughs. All rights reserved.
//

import UIKit

class LaundryRoomTableViewController: UITableViewController {
    
    
    //MARK: Properties
    
    var laundryRooms = [LaundryRoom]()
    let service = LVAPIService()
    var school : School?
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        if(UserDefaults.standard.string(forKey: "roomId") != nil) {
//            self.performSegue(withIdentifier: "ShowMachines", sender: self)
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(UserDefaults.standard.string(forKey: "schoolId") != nil) {
            school = School(
                id: UserDefaults.standard.string(forKey: "schoolId")!,
                name: UserDefaults.standard.string(forKey: "schoolName")!
            )
        } else {
            self.performSegue(withIdentifier: "OpenSearch", sender: self)
        }
        
        self.title = school?.name
        loadRooms()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return laundryRooms.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LaundryRoomCell", for: indexPath)

        let laundryRoom = laundryRooms[indexPath.row]

        cell.textLabel?.text = laundryRoom.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if UserDefaults.standard.string(forKey: "roomId") == nil {
            saveStuff(at: indexPath)
            performSegue(withIdentifier: "toTabBarSegue", sender: self)
        } else {
            saveStuff(at: indexPath)
            self.dismiss(animated: true)
        }
    }
    
    func saveStuff(at indexPath: IndexPath) {
        let room = laundryRooms[indexPath.row]
        
        UserDefaults.standard.set(room.id, forKey: "roomId")
        UserDefaults.standard.set(room.name, forKey: "roomName")
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: .requestMachineDataReload, object: nil)
    }
    
    //MARK: Private Methods
    
    private func loadRooms() {
        guard school != nil else {
            return
        }
        
        service.findLaundryRooms(school: school!) { (lrs : [LaundryRoom]) in
            self.laundryRooms = lrs
            self.tableView?.reloadData()
        }
    }

}
