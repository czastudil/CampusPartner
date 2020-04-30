//
//  Profile_Creation.swift
//  CampusPartner
//
//  Created by Cindy Zastudil on 2/25/20.
//  Copyright © 2020 Cindy Zastudil. All rights reserved.
//

import UIKit

class ProfileCreation: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var avoidStairsSwitch: UISwitch!
    @IBOutlet weak var avoidUnpavedRoads: UISwitch!
    @IBOutlet weak var maxElevation: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avoidStairsSwitch.isOn = true
    }
    
    // MARK: Actions
    
    @IBAction func saveProfile(_ sender: Any) {
        let defaults = UserDefaults.standard
        if let firstName = firstNameField.text, let lastName = lastNameField.text{
            if !firstName.isEmpty && !lastName.isEmpty {
                defaults.set(firstName, forKey: "firstName")
                defaults.set(lastName, forKey: "lastName")
                defaults.set(avoidStairsSwitch.isOn, forKey: "avoidStairs")
                defaults.set(avoidUnpavedRoads.isOn, forKey: "avoidUnpavedRoads")
                if maxElevation.text!.isEmpty {
                    defaults.set(0, forKey: "maxElevation")
                } else {
                    defaults.set(maxElevation.text, forKey: "maxElevation")
                }
            } else {
                let alert = UIAlertController(title: "Missing one or more required fields", message: "First and last name are required fields.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true)
            }
        } else {
            let alert = UIAlertController(title: "Missing one or more required fields", message: "First and last name are required fields.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if let ident = identifier {
            if ident == "saveSegue" {
                let defaults = UserDefaults.standard
                if let firstName = firstNameField.text, let lastName = lastNameField.text{
                    if !firstName.isEmpty && !lastName.isEmpty {
                        defaults.set(firstName, forKey: "firstName")
                        defaults.set(lastName, forKey: "lastName")
                        defaults.set(avoidStairsSwitch.isOn, forKey: "avoidStairs")
                        return true
                    } else {
                        let alert = UIAlertController(title: "Missing one or more required fields", message: "First and last name are required fields.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        self.present(alert, animated: true)
                        return false
                    }
                } else {
                    let alert = UIAlertController(title: "Missing one or more required fields", message: "First and last name are required fields.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                    return false
                }
            }
        }
        return true
    }
}
