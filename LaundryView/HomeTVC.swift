//
//  HomeTVC.swift
//  LaundryView
//
//  Created by Oliver Elliott on 8/7/22.
//  Copyright © 2022 Jacob Burroughs. All rights reserved.
//

import UIKit

class HomeTVC: UITableViewController {
    
    var currentMachines: [CurrentMachine] = []
    var progressViews: [CircularProgressBarView] = []
    
    var machinesSection: Int {
        return currentMachines.isEmpty ? 1 : 2
    }
    
    var currentMachinesSection: Int? {
        return currentMachines.isEmpty ? nil : 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRoomName()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMachines), name: .machineDataReloaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMachines), name: .reloadHomeTVC, object: nil)
        self.refreshControl?.addTarget(self, action: #selector(loadMachines), for: UIControl.Event.valueChanged)
        currentMachines = CurrentMachineCache.getAndFilter()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var amount = 1
        if machines != nil {
            amount += 1
        }
        if !currentMachines.isEmpty {
            amount += 1
        }
        return amount
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentMachinesSection == section {
            return currentMachines.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "changeLocationCell", for: indexPath)
            return cell
        } else if let currentMachinesSection = currentMachinesSection, currentMachinesSection == indexPath.section {
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeLeftCell", for: indexPath) as! TimeLeftCell
            
            let machine = currentMachines[indexPath.row]
            cell.machineImage.image = UIImage(named: machine.type == .washer ? "washerIcon" : "dryerIcon")?.withRenderingMode(.alwaysTemplate)
            if #available(iOS 13.0, *) {
                cell.machineImage.tintColor = .secondaryLabel
            }
            cell.machineNumberLabel.text = "\(machine.type.rawValue) #\(machine.number)"
            
            cell.timeLeftLabel.text = "Done"
            if let dateDone = machine.dateDone {
                let difference = Calendar.current.dateComponents([.minute], from: Date(), to: dateDone).minute ?? 0
                if difference > 0 {
                    cell.timeLeftLabel.text = "\(difference) minute\(difference == 1 ? "" : "s") left"
                }
            }
            
            cell.xButton.tag = indexPath.row
            cell.xButton.addTarget(self, action: #selector(removeCurrentMachine), for: .touchDown)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "machinesAvailableCell", for: indexPath) as! MachinesAvailableCell
            
            cell.washerView.layer.cornerRadius = 10
            cell.dryerView.layer.cornerRadius = 10
            
            cell.washerImage.image = UIImage(named: "washerIcon")?.withRenderingMode(.alwaysTemplate)
            cell.dryerImage.image = UIImage(named: "dryerIcon")?.withRenderingMode(.alwaysTemplate)
            
            if machines![.washer]?.allSatisfy({ $0.status == .unknown }) ?? true {
                cell.washersAvailableLabel.text = "Status Unknown"
                if #available(iOS 13.0, *) {
                    cell.washerImage.tintColor = .secondaryLabel
                }
            } else {
                let availableWashers = machines![.washer]?.filter({ $0.status == .available }) ?? []
                cell.washersAvailableLabel.text = "\(availableWashers.count) Washer\(availableWashers.count == 1 ? "" : "s") Available"
                
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
                cell.dryersAvailableLabel.text = "\(availableDryers.count) Dryer\(availableDryers.count == 1 ? "" : "s") Available"
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
        currentMachines = CurrentMachineCache.getAndFilter()
        tableView.reloadData()
        refreshControl?.endRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for i in 0 ..< self.currentMachines.count {
                let currentMachine = self.currentMachines[i]
                if let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 1)) as? TimeLeftCell, let dateDone = currentMachine.dateDone {
                    cell.circularProgressBarView?.removeFromSuperview()
                    cell.circularProgressBarView = CircularProgressBarView(frame: cell.machineImageHoldingView.frame)
                    cell.circularProgressBarView!.createCircularPath()
                    cell.addSubview(cell.circularProgressBarView!)
                    let difference = Calendar.current.dateComponents([.minute], from: Date(), to: dateDone).minute ?? 0
                    if difference > 0 {
                        let timeFromStart = Double(Calendar.current.dateComponents([.minute], from: currentMachine.startDate, to: Date()).minute ?? 0)
                        let totalTime = Double(Calendar.current.dateComponents([.minute], from: currentMachine.startDate, to: dateDone).minute ?? 0)
                        cell.circularProgressBarView!.animate(to: timeFromStart/totalTime)
                    } else {
                        cell.circularProgressBarView!.finishAnimation()
                    }
                }
            }
        }
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
    
    @objc func removeCurrentMachine(_ button: UIButton) {
        let index = button.tag
        CurrentMachineCache.removeMachine(with: currentMachines[index].id)
        currentMachines.remove(at: index)
        if currentMachines.isEmpty {
            tableView.deleteSections([1], with: .automatic)
        } else {
            tableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
        }
    }
    
}

class TimeLeftCell: UITableViewCell {
    
    var circularProgressBarView: CircularProgressBarView?
    
    @IBOutlet var machineImageHoldingView: UIView!
    @IBOutlet var machineImage: UIImageView!
    @IBOutlet var timeLeftLabel: UILabel!
    @IBOutlet var machineNumberLabel: UILabel!
    @IBOutlet var xButton: UIButton!
    
}

class MachinesAvailableCell: UITableViewCell {
    
    @IBOutlet var washerView: UIView!
    @IBOutlet var washerImage: UIImageView!
    @IBOutlet var washersAvailableLabel: UILabel!
    @IBOutlet var dryerView: UIView!
    @IBOutlet var dryerImage: UIImageView!
    @IBOutlet var dryersAvailableLabel: UILabel!
    
}
