//
//  MachinesTableViewController.swift
//  LaundryView
//
//  Created by Jacob Burroughs on 10/18/17.
//  Copyright © 2017 Jacob Burroughs. All rights reserved.
//

import UIKit

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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MachineCell", for: indexPath)
        
        guard machines != nil else {
            return cell
        }
        guard machines![type] != nil else {
            return cell
        }
        
        let machine = machines![type]![indexPath.row]
        
        let machineCell = cell as! MachineTableViewCell
        
        machineCell.numberLabel?.text = machine.number
        
        var statusText : String
        var statusColor : UIColor
        
        switch machine.status {
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
        
        machineCell.key = "\(room!.name)|\(room!.id)|\(machine.id)"
        if(machine.status == Status.inUse) {
            machineCell.alertSwitch.isHidden = false
            if(UserDefaults.standard.bool(forKey: machineCell.key)) {
                machineCell.alertSwitch.isOn = true
            } else {
                machineCell.alertSwitch.isOn = false
            }
        } else {
            machineCell.alertSwitch.isHidden = true
        }
 
        machineCell.statusLabel?.text = statusText
        machineCell.backndView.backgroundColor = statusColor
        machineCell.backndView.layer.cornerRadius = 8
        if (machine.timeRemaining != nil) {
            machineCell.remainingLabel?.text = "\(machine.timeRemaining!) minutes remaining"
            machineCell.remainingLabel?.isHidden = false
        } else {
            machineCell.remainingLabel?.isHidden = true
        }
        
        
        return cell
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
