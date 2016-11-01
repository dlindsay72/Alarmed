//
//  MainVC.swift
//  Alarmed
//
//  Created by Dan Lindsay on 2016-10-27.
//  Copyright © 2016 Dan Lindsay. All rights reserved.
//

import UIKit

class MainVC: UITableViewController {
    
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
    
    
}






























