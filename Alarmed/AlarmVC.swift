//
//  AlarmVC.swift
//  Alarmed
//
//  Created by Dan Lindsay on 2016-10-27.
//  Copyright © 2016 Dan Lindsay. All rights reserved.
//

import UIKit

class AlarmVC: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var caption: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tapToSelectImage: UILabel!
    
    var alarm: Alarm!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = alarm.name
        name.text = alarm.name
        caption.text = alarm.caption
        datePicker.date = alarm.time
        
        if alarm.image.characters.count > 0 {
            //if we have an image, try to load it
            let imageFileName = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            
            imageView.image = UIImage(contentsOfFile: imageFileName.path)
            
            tapToSelectImage.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func datePickerChanged(_ sender: AnyObject) {
        
        alarm.time = datePicker.date
    }

    @IBAction func imageViewTapped(_ sender: AnyObject) {
        
        let vc = UIImagePickerController()
        vc.modalPresentationStyle = .formSheet
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        alarm.name = name.text!
        alarm.caption = caption.text!
        title = alarm.name
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //dismiss the image picker
        dismiss(animated: true)
        
        //fetch the image that was picked
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
        
        let fm = FileManager()
        
        if alarm.image.characters.count > 0 {
            //the alarm already has an image, so delete it
            do {
                let currentImage = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
                
                if fm.fileExists(atPath: currentImage.path) {
                    try fm.removeItem(at: currentImage)
                }
            } catch {
                print("Failed to remove current image")
            }
        }
        do {
           //generate a new filename for the image
            alarm.image = "\(UUID().uuidString).jpg"
            
            //write a new image to the documents directory
            let newPath = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            
            let jpeg = UIImageJPEGRepresentation(image, 80)
            try jpeg?.write(to: newPath)
        } catch {
            print("Failed to save new image")
        }
        //update the user interface
        imageView.image = image
        tapToSelectImage.isHidden = true
    }

    
}


















