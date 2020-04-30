//
//  EditProfile.swift
//  CampusPartner
//
//  Created by Cindy Zastudil on 4/8/20.
//  Copyright © 2020 Cindy Zastudil. All rights reserved.
//

import UIKit

class EditProfile: UIViewController {
    @IBOutlet weak var stairsSwitch: UISwitch!
    @IBOutlet weak var unpavedSwitch: UISwitch!
    @IBOutlet weak var maxElevationSwitch: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var warning: UILabel!
    @IBOutlet weak var warningMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add actions for if any of the fields change
        firstNameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        lastNameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        maxElevationSwitch.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        stairsSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: UIControl.Event.valueChanged)
        unpavedSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: UIControl.Event.valueChanged)
        
        let defaults = UserDefaults.standard
        profileName.text = defaults.string(forKey: "firstName")! + " " + defaults.string(forKey: "lastName")! + "'s Profile"
        
        // Show the user's current preferences on this screen so they know what they are
        stairsSwitch.isOn = defaults.bool(forKey: "avoidStairs")
        unpavedSwitch.isOn = defaults.bool(forKey: "avoidUnpavedRoads")
        // Zero indicates no preference on elevation change
        if defaults.string(forKey: "maxElevation")! == "0" {
            maxElevationSwitch.text! = "None"
        } else {
            maxElevationSwitch.text! = defaults.string(forKey: "maxElevation")!
        }
        firstNameField.text! = defaults.string(forKey: "firstName")!
        lastNameField.text! = defaults.string(forKey: "lastName")!
        
        self.warning.isHidden = true
        self.warningMessage.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaults = UserDefaults.standard
        profileName.text = defaults.string(forKey: "firstName")! + " " + defaults.string(forKey: "lastName")! + "'s Profile"
        
        // Show the user's current preferences on this screen so they know what they are
        stairsSwitch.isOn = defaults.bool(forKey: "avoidStairs")
        unpavedSwitch.isOn = defaults.bool(forKey: "avoidUnpavedRoads")
        // Zero indicates no preference on elevation change
        if defaults.string(forKey: "maxElevation")! == "0" {
            maxElevationSwitch.text! = "None"
        } else {
            maxElevationSwitch.text! = defaults.string(forKey: "maxElevation")!
        }
        firstNameField.text! = defaults.string(forKey: "firstName")!
        lastNameField.text! = defaults.string(forKey: "lastName")!
        
        self.warning.isHidden = true
        self.warningMessage.isHidden = true
    }
    
    @objc func textFieldDidChange(_ textfield: UITextField) {
        self.warning.isHidden = false
        self.warningMessage.isHidden = false
    }
    
    @objc func switchValueDidChange(_ sender : UISwitch) {
        self.warning.isHidden = false
        self.warningMessage.isHidden = false
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        let defaults = UserDefaults.standard
        
        // Set the value of first name
        if !firstNameField.text!.isEmpty {
            defaults.set(firstNameField.text!, forKey: "firstName")
        }
        
        // Set the value of last name
        if !lastNameField.text!.isEmpty {
            defaults.set(lastNameField.text!, forKey: "lastName")
        }
        
        // Update the page title text
        profileName.text = defaults.string(forKey: "firstName")! + " " + defaults.string(forKey: "lastName")! + "'s Profile"
        
        // Set the value of avoidStairs
        defaults.set(stairsSwitch.isOn, forKey: "avoidStairs")
        
        // Set the value of the avoidUnpavedRoads
        defaults.set(unpavedSwitch.isOn, forKey: "avoidUnpavedRoads")
        
        // Set the value of maxElevation
        if !maxElevationSwitch.text!.isEmpty {
            defaults.set(maxElevationSwitch.text!, forKey: "maxElevation")
        } else {
            defaults.set("0", forKey: "maxElevation")
        }
        
        self.warning.isHidden = true
        self.warningMessage.isHidden = true
    }
    
}
