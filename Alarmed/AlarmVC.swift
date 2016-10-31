//
//  AlarmVC.swift
//  Alarmed
//
//  Created by Dan Lindsay on 2016-10-27.
//  Copyright © 2016 Dan Lindsay. All rights reserved.
//

import UIKit

class AlarmVC: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var caption: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tapToSelectImage: UILabel!
    
    var alarm: Alarm!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func datePickerChanged(_ sender: AnyObject) {
        
    }

    @IBAction func imageViewTapped(_ sender: AnyObject) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        alarm.name = name.text!
        title = alarm.name
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    

}
