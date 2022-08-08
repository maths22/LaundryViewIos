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
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMachines), name: .machineDataReloaded, object: nil)
        self.refreshControl?.addTarget(self, action: #selector(loadMachines), for: UIControl.Event.valueChanged)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if machines == nil {
            return 1
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "changeLocationCell", for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "machinesAvailableCell", for: indexPath) as! MachinesAvailableCell
            
            cell.washerImage.image = UIImage(named: "washerIcon")?.withRenderingMode(.alwaysTemplate)
            cell.dryerImage.image = UIImage(named: "dryerIcon")?.withRenderingMode(.alwaysTemplate)
            
            if machines![.washer]?.allSatisfy({ $0.status == .unknown }) ?? true {
                cell.washersAvailableLabel.text = "Status Unknown"
                if #available(iOS 13.0, *) {
                    cell.washerImage.tintColor = .secondaryLabel
                }
            } else {
                let availableWashers = machines![.washer]?.filter({ $0.status == .available }) ?? []
                cell.washersAvailableLabel.text = "\(availableWashers.count) washer\(availableWashers.count == 1 ? "" : "s") available"
                
                if #available(iOS 13.0, *) {
                    cell.washerImage.tintColor = availableWashers.isEmpty ? .systemRed : .systemGreen
                }
            }
            
            if machines![.dryer]?.allSatisfy({ $0.status == .unknown }) ?? true {
                cell.dryersAvailableLabel.text = "Status Unknown"
                if #available(iOS 13.0, *) {
                    cell.dryerImage.tintColor = .secondaryLabel
                }
            } else {
                let availableDryers = machines![.dryer]?.filter({ $0.status == .available }) ?? []
                cell.dryersAvailableLabel.text = "\(availableDryers.count) dryer\(availableDryers.count == 1 ? "" : "s") available"
                if #available(iOS 13.0, *) {
                    cell.dryerImage.tintColor = availableDryers.isEmpty ? .systemRed : .systemGreen
                }
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func reloadMachines() {
        setRoomName()
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    
    func setRoomName() {
        if let roomName = UserDefaults.standard.string(forKey: "roomName") {
            title = roomName
            tabBarController?.tabBar.items?[0].title = "Home"
        } else {
            title = "Home"
        }
    }
    
    @objc func loadMachines() {
        NotificationCenter.default.post(name: .requestMachineDataReload, object: nil)
    }
    
}

class TimeLeftCell: UITableViewCell {
    
    @IBOutlet var machineImage: UIImageView!
    @IBOutlet var timeLeftLabel: UILabel!
    @IBOutlet var machineNumberLabel: UILabel!
    
}

class MachinesAvailableCell: UITableViewCell {
    
    @IBOutlet var washerImage: UIImageView!
    @IBOutlet var washersAvailableLabel: UILabel!
    @IBOutlet var dryerImage: UIImageView!
    @IBOutlet var dryersAvailableLabel: UILabel!
    
}
