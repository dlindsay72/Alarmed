//
//  MainVC.swift
//  Alarmed
//
//  Created by Dan Lindsay on 2016-10-27.
//  Copyright © 2016 Dan Lindsay. All rights reserved.
//

import UIKit
import UserNotifications

class MainVC: UITableViewController, UNUserNotificationCenterDelegate {
    
    var groups = [Group]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let titleAttributes = [NSFontAttributeName: UIFont(name: "Arial Rounded MT Bold", size: 20)!]
        
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        
        title = "Alarmed"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGroup))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Groups", style: .plain, target: nil, action: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: Notification.Name("save"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        load()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        groups.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        save()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Group", for: indexPath)
        let group = groups[indexPath.row]
        
        cell.textLabel?.text = group.name
        
        if group.enabled {
            cell.textLabel?.textColor = UIColor.black
        } else {
            cell.textLabel?.textColor = UIColor.red
        }
        
        if group.alarms.count == 1 {
            cell.detailTextLabel?.text = "1 alarm"
        } else {
            cell.detailTextLabel?.text = "\(group.alarms.count) alarms"
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let groupToEdit: Group
        
        if sender is Group {
            
            //we were called from addGroup(); use what is sent to us
            groupToEdit = sender as! Group
        } else {
        
            //we were called by a tableView cell; figure out which group we're attached to send
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
            
            groupToEdit = groups[selectedIndexPath.row]
        }
        //unwrap our destination from the segue
        if let groupViewController = segue.destination as? GroupVC {
            
            //give it whatever group we decided above
            groupViewController.group = groupToEdit
        }
        
    }
    
    func addGroup() {
        
        let newGroup = Group(name: "Name", playSound: true, enabled: false, alarms: [])
        
        groups.append(newGroup)
        
        performSegue(withIdentifier: "EditGroup", sender: newGroup)
        
        save()
    }
    
    func save() {
        
        do {
            
            let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
            let data = NSKeyedArchiver.archivedData(withRootObject: groups)
            
            try data.write(to: path)
            
        } catch {
            
            print("Failed to save")
        }
        
        
        updateNotifications()
    }
    
    func load() {
        
        do {
            
            let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
            let data = try Data(contentsOf: path)
            
            groups = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Group] ?? [Group]()
            
        } catch {
            
            print("Failed to load")
        }
    }
    
    func updateNotifications() {
        
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { [unowned self] (granted, error) in
            
            if granted {
                self.createNotifications()
            }
        }
    }
    
    func createNotifications() {
        
        let center = UNUserNotificationCenter.current()
        
        //remove any pending notifications
        center.removeAllPendingNotificationRequests()
        
        for group in groups {
            
            //ignore disabled groups
            guard group.enabled == true else { continue }
            
            for alarm in group.alarms {
                
                //create a notification request for each alarm
                let notification = createNotificationRequest(group: group, alarm: alarm)
                
                //schedule that notification for delivery
                center.add(notification) { error in
                    
                    if let error = error {
                        print("Error scheduling notifications: \(error)")
                    }
                }
            }
        }
    }
    
    func createNotificationRequest(group: Group, alarm: Alarm) -> UNNotificationRequest{
        
        //start by creating the contnent for the notification
        let content = UNMutableNotificationContent()
        
        //assign the users name and caption
        content.title = alarm.name
        content.body = alarm.caption
        
        //give it an identifier we can attach to custom buttons later on
        content.categoryIdentifier = "alarm"
        
        //attach the group ID and alarm ID for this alarm
        content.userInfo = ["group": group.id, "alarm": alarm.id]
        
        //if the user requested a sound for this group, attach their default alert sound
        if group.playSound {
            
            content.sound = UNNotificationSound.default()
        }
        //use createNotificationAttachments to attach a picture for this alert if there is one
        content.attachments = createNotificationAttachments(alarm: alarm)
        
        //get a calendar ready to pull out the date components
        let cal = Calendar.current
        
        //pull out the hour and minute from this alarm's date
        var dateComponents = DateComponents()
        dateComponents.hour = cal.component(.hour, from: alarm.time)
        dateComponents.minute = cal.component(.minute, from: alarm.time)
        
        //create a trigger matching those date components, set to repeat
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        //testing trigger
       // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: true)
        
        //combine the content and the trigger to create a notification request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        //pass that object back to createNotifications() for scheduling
        return request
    }
    
    func createNotificationAttachments(alarm: Alarm) -> [UNNotificationAttachment] {
        
        //return if there is no image to attach
        guard alarm.image.characters.count > 0 else { return [] }
    
        let fm = FileManager.default
        
        do {
            //get the full path to the alrm image
            let imageURL = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
            
            //create a temporary filename
            let copyURL = Helper.getDocumentsDirectory().appendingPathComponent("(UUID().uuidString).jpg")
            
            //copy the alrm image to the temporary filename
            try fm.copyItem(at: imageURL, to: copyURL)
            
            //create an attachment from the temporary filename, giving it a random identifier
            let attachment = try UNNotificationAttachment(identifier: UUID().uuidString, url: copyURL)
            
            //return the attachment back to the createNotificationRequest()
            return [attachment]
        } catch {
            print("Failed to attach alarm image: \(error)")
            return []
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func display(group groupID: String) {
        
        _ = navigationController?.popToRootViewController(animated: false)
        
        for group in groups {
            if group.id == groupID {
                
                performSegue(withIdentifier: "EditGroup", sender: group)
                
                return
            }
        }
    }
    
    func destroy(group groupID: String) {
        
        _ = navigationController?.popToRootViewController(animated: false)
        
        for (index, group) in groups.enumerated() {
            if group.id == groupID {
                groups.remove(at: index)
                break
            }
        }
        
        save()
        load()
    }
    
    func rename(group groupID: String, newName: String) {
        
        _ = navigationController?.popToRootViewController(animated: false)
        
        for group in groups {
            
            if group.id == groupID {
                group.name = newName
                break
            }
        }
        
        save()
        load()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //pull out the buried userInfo dictionary
        let userInfo = response.notification.request.content.userInfo
        
        if let groupID = userInfo["group"] as? String {
            
            //if we got a groupID, we're good to go
            
            switch response.actionIdentifier {
                //the user swiped to unlock; do nothing
            case UNNotificationDefaultActionIdentifier:
                print("Default identifier")
                //the user dismissed the alert; do nothing
            case UNNotificationDismissActionIdentifier:
                print("Dismiss identifier")
                
                //the user asked to see the group, so call the display() method
            case "show":
                display(group: groupID)
                break
                
                //the user asked to destroy the group, so call the destroy method
            case "destroy":
                destroy(group: groupID)
                
                //the user asked to rename the group, so safely unwrap their text response and call rename
            case "rename":
                    if let textResponse = response as? UNTextInputNotificationResponse {
                        rename(group: groupID, newName: textResponse.userText)
                }
                break
                
            default:
                break
                
            }
        }
        //you need to call the completionHandler when you are done
        completionHandler()
    }
    
}






























