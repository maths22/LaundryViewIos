//
//  MachineTableViewCell.swift
//  LaundryView
//
//  Created by Jacob Burroughs on 10/18/17.
//  Copyright © 2017 Jacob Burroughs. All rights reserved.
//

import UIKit
import BadgeSwift

class MachineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backndView: UIView!
    @IBOutlet weak var numberLabel: BadgeSwift!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var alertSwitch: UISwitch!
    var key: String = ""
    let service = LVAPIService()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        numberLabel.layer.cornerRadius = 8.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func switchChanged(_ sender: Any) {
        UserDefaults.standard.set(alertSwitch.isOn, forKey: key)
//        guard let token = UserDefaults.standard.string(forKey: "firebaseToken") else {
//            return
//        }
//        if(alertSwitch.isOn) {
//            service.registerNotification(machineId: key, requesterId: token)
//        } else {
//            service.unregisterNotification(machineId: key, requesterId: token)
//        }
        
    }
}
