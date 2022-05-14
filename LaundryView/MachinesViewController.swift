//
//  MachinesTableViewController.swift
//  LaundryView
//
//  Created by Jacob Burroughs on 10/18/17.
//  Copyright © 2017 Jacob Burroughs. All rights reserved.
//

import UIKit
import UserNotifications
import StoreKit

class MachinesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var machineTypeSelector: UISegmentedControl!
    @IBOutlet weak var machineTable: UITableView!
    
    let badgeColorGreen = UIColor(red:0.00, green:0.90, blue:0.46, alpha:1.0)
    let badgeColorYellow = UIColor(red:1.00, green:0.92, blue:0.00, alpha:1.0)
    let badgeColorRed = UIColor(red:0.90, green:0.45, blue:0.45, alpha:1.0)

    let service = LVAPIService()
    var room : LaundryRoom?
    var machines : [MachineType: [Machine]]?
    var type = MachineType.washer
    
    @IBAction func selectMachineType(_ sender: Any) {
        if(machineTypeSelector.selectedSegmentIndex == 0) {
            type = MachineType.washer
        } else {
            type = MachineType.dryer
        }
        self.machineTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        machineTable.delegate = self
        machineTable.dataSource = self

        if #available(iOS 10.0, *) {
            machineTable.refreshControl = refreshControl
        } else {
            machineTable.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(loadMachines), for: .valueChanged)
        
        if(UserDefaults.standard.string(forKey: "roomId") != nil) {
            room = LaundryRoom(
                id: UserDefaults.standard.string(forKey: "roomId")!,
                name: UserDefaults.standard.string(forKey: "roomName")!
            )
        }
        
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = room?.name
        
        loadMachines()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard machines != nil else {
            return 0
        }
        guard machines![type] != nil else {
            return 0
        }
        return machines![type]!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MachineCell", for: indexPath) as! MachineTableViewCell
        
        guard machines != nil else {
            return cell
        }
        guard machines![type] != nil else {
            return cell
        }
        
        cell.alertSwitch.tag = indexPath.row
        cell.alertSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        let machine = machines![type]![indexPath.row]
        
        let status: Status = machine.status == .inUse && machine.timeRemaining == nil ? .done : machine.status
        
        cell.numberLabel?.text = machine.number
        
        var statusText : String
        var statusColor : UIColor
        
        switch status {
        case .available:
            statusColor = badgeColorGreen
            statusText = "Available"
        case .inUse:
            statusColor = badgeColorRed
            statusText = "In Use"
        case .done:
            statusColor = badgeColorYellow
            statusText = "Done"
        case .outOfService:
            statusColor = UIColor.lightGray
            statusText = "Out of Service"
        case .unknown:
            statusColor = UIColor.lightGray
            statusText = "Unknown"
        }
        
        cell.key = "\(room!.name)|\(room!.id)|\(machine.id)"
        if (status == .inUse) {
            cell.alertSwitch.isHidden = false
//            if(UserDefaults.standard.bool(forKey: cell.key)) {
//                cell.alertSwitch.isOn = true
//            } else {
//                cell.alertSwitch.isOn = false
//            }
            let center = UNUserNotificationCenter.current()
            cell.alertSwitch.isOn = false
            center.getPendingNotificationRequests(completionHandler: { requests in
                for request in requests {
                    if request.identifier == machine.id {
                        DispatchQueue.main.async {
                            cell.alertSwitch.isOn = true
                        }
                        break
                    }
                }
            })
        } else {
            cell.alertSwitch.isHidden = true
        }
 
        cell.statusLabel?.text = statusText
        cell.backndView.backgroundColor = statusColor
        cell.backndView.layer.cornerRadius = 8
        if let time = machine.timeRemaining {
            let s = time == 1 ? "" : "s"
            cell.remainingLabel?.text = "\(time) minute\(s) remaining"
            cell.remainingLabel?.isHidden = false
        } else {
            cell.remainingLabel?.isHidden = true
        }
        
        
        return cell
    }
    
    @objc func switchChanged(_ thisSwitch: UISwitch) {
        guard machines != nil else {
            printError()
            return
        }
        guard machines![type] != nil else {
            printError()
            return
        }
        
        let machine = machines![type]![thisSwitch.tag]
        
        if machine.timeRemaining == nil {
            printError()
            return
        }
        
        if thisSwitch.isOn {
            let content = UNMutableNotificationContent()
            let type = machine.type == .washer ? "washer" : "dryer"
            var number = machine.number
            if machine.number.first == "0" {
                number.removeFirst()
            }
//            content.title = "LaundryView"
            content.body = "Your laundry in \(type) #\(number) is done"
            content.sound = UNNotificationSound.default

            // show this notification five seconds from now
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60*Double(machine.timeRemaining!), repeats: false)

            // choose a random identifier
            let request = UNNotificationRequest(identifier: machine.id, content: content, trigger: trigger)

            // add our notification request
            UNUserNotificationCenter.current().add(request)
        } else {
            let center = UNUserNotificationCenter.current()
            center.removeDeliveredNotifications(withIdentifiers: [machine.id])
            center.removePendingNotificationRequests(withIdentifiers: [machine.id])
        }
        
        
        
    }
    
    func printError() {
        let alert = UIAlertController(title: "Error", message: "Error setting notification for washer/dryer, please try again", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Dismiss", style: .default)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc
    private func loadMachines() {
        guard room != nil else {
            return
        }
        
        self.refreshControl.beginRefreshing()
        service.machineStatus(laundryRoom: room!, completion: { (machines : [MachineType: [Machine]]) in
            self.machines = machines
            self.machineTable.reloadData()
            self.refreshControl.endRefreshing()
        })
    }

}
