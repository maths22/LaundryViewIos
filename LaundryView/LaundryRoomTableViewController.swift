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
        if(UserDefaults.standard.string(forKey: "roomId") != nil) {
            self.performSegue(withIdentifier: "ShowMachines", sender: self)
        }
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "ShowMachines":
            guard let selectedMealCell = sender as? UITableViewCell else {
                // Don't update the prefs if this launch is based on prefs
                return
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let room = laundryRooms[indexPath.row]
            
            UserDefaults.standard.set(room.id, forKey: "roomId")
            UserDefaults.standard.set(room.name, forKey: "roomName")
            UserDefaults.standard.synchronize()
            
        default:
            break
        }
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
