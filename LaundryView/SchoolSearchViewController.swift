//
//  SchoolSearchViewController.swift
//  LaundryView
//
//  Created by Jacob Burroughs on 10/18/17.
//  Copyright © 2017 Jacob Burroughs. All rights reserved.
//

import UIKit
import JGProgressHUD

class SchoolSearchViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    let service = LVAPIService()
    var schools = [School]()

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "School name"
        searchController.delegate = self
        self.tableView.tableHeaderView = searchController.searchBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        searchController.isActive = true
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        self.searchController.searchBar.becomeFirstResponder()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schools.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolCell", for: indexPath)
        
        let school = schools[indexPath.row]
        
        cell.textLabel?.text = school.name
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard(searchController.searchBar.text != nil) else {
            return;
        }
        guard(searchController.searchBar.text!.count >= 3) else {
            return;
        }
        
        let hud = JGProgressHUD()
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 1.0)
        service.findSchools(name: searchController.searchBar.text!, completion: { (schools : [School]) in
            hud.dismiss()
            self.schools = schools
            self.tableView?.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.standard.set(schools[indexPath.row].id, forKey: "schoolId")
        UserDefaults.standard.set(schools[indexPath.row].name, forKey: "schoolName")
        UserDefaults.standard.synchronize()
        
        searchController.dismiss(animated: true)
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
