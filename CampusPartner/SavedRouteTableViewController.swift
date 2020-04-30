//
//  SavedRouteTableViewController.swift
//  CampusPartner
//
//  Created by Cindy Zastudil on 4/14/20.
//  Copyright © 2020 Cindy Zastudil. All rights reserved.
//

import UIKit
import os.log

var routes = [Route]()

class SavedRouteTableViewController: UITableViewController {

    // MARK: Properties
    
    var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        if let savedRoutes = loadRoutes() {
            routes += savedRoutes
        }
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // Save the routes when you leave the table view in the app
    override func viewWillDisappear(_ animated: Bool) {
        saveRoutes()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SavedRouteTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SavedRouteTableViewCell else {
            fatalError("The dequeued cell is not an instance of SavedRouteTableViewCell")
        }
        let route = routes[indexPath.row]
        cell.routeLabel.text = route.routeTitle

        return cell
    }
 
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            routes.remove(at: indexPath.row)
            saveRoutes()
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }   
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let selectedRoute = routes[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "saveToNav", sender: cell)
        //let navigation: Navigation = (storyboard?.instantiateViewController(withIdentifier: "Navigation"))! as! Navigation
        //navigation.loadSavedRoute(route: selectedRoute)
        //self.present(navigation, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveToNav" {
            //let senderCell = sender as? RouteStepTableViewCell
            let yourController = segue.destination as? Navigation

            yourController!.savedRouteIndex = selectedIndex
        }
    }
 

    /* TODO: REMOVE ANY OF THESE FUNCTIONS THAT ARE UNUSED
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

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: Private Methods
    
    private func saveRoutes() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(routes, toFile: Route.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Routes successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save routes...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadRoutes() -> [Route]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Route.ArchiveURL.path) as? [Route]
    }
}
