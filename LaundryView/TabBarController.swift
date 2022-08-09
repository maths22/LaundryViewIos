//
//  TabBarController.swift
//  LaundryView
//
//  Created by Oliver Elliott on 8/7/22.
//  Copyright © 2022 Jacob Burroughs. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    let service = LVAPIService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMachines), name: .requestMachineDataReload, object: nil)
        reloadMachines()
    }
    
    @objc func reloadMachines() {
        service.reloadMachines()
    }
    
}
