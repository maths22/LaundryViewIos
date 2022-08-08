//
//  HomeTVC.swift
//  LaundryView
//
//  Created by Oliver Elliott on 8/7/22.
//  Copyright © 2022 Jacob Burroughs. All rights reserved.
//

import UIKit

class HomeTVC: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRoomName()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMachines), name: .changedLocation, object: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "changeLocationCell", for: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func reloadMachines() {
        setRoomName()
    }
    
    func setRoomName() {
        if let roomName = UserDefaults.standard.string(forKey: "roomName") {
            title = roomName
            tabBarController?.tabBar.items?[0].title = "Home"
        } else {
            title = "Home"
        }
    }
    
}
