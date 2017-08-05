//
//  StudentTableViewController.swift
//  On The Map
//
//  Created by Anthony Guella on 7/30/17.
//  Copyright © 2017 Anthony Guella. All rights reserved.
//

import UIKit

class StudentTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Variables
    var overlay = LoadingOverlayView()
    var refreshButton: UIButton?
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
        self.setupNavigationBarItems()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: Methods
    private func updateStudents() {
        DispatchQueue.global(qos: .userInitiated).async{
            Parse.sharedInstance().getStudentLocations(nil) { (success, error) in
                guard (error == nil) else {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Error", message: "Could not load student data", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                        self.refreshButton!.isEnabled = true
                    }
                    return
                }
            }
        }
    }
    
    func updateTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshButton!.isEnabled = true
            self.overlay.hideOverlayView()
        }
    }
    
    func showOverlay() {
        refreshButton!.isEnabled = false
        overlay.showOverlay(view: self.view)
    }
    
    private func presentPostViewController() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    //MARK: IBActions
    func refreshButtonPressed() {
        let nc = NotificationCenter.default
        nc.post(Notification(name: Notification.Name(rawValue: "refreshPressed")))
        Parse.sharedInstance().isUpdating = true
        self.updateStudents()
    }
    
    func logoutButtonPressed() {
        UdacityClient.sharedInstance().logout { (success, error) in
            guard (error == nil) else {
                print("Error logging out")
                return
            }
            
            if success {
                print("Successfully logged out")
            }
        }
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoginVC")
        self.present(vc, animated: true, completion: nil)
    }
    
    func addButtonPressed() {
        if StudentsModel.sharedInstance().student != nil {
            let message = "User \"\(StudentsModel.sharedInstance().student!.firstName!) \(StudentsModel.sharedInstance().student!.lastName!)\" Has Already Posted a Student Location. Would You Like to Overwrite Their Location?"
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Overwrite", style: .default, handler: { (action) in
                self.presentPostViewController()
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            self.presentPostViewController()
        }
    }
    
    //MARK: View Setup
    private func addObservers() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateTableView), name: Notification.Name(rawValue: "studentsChanged"), object: nil)
        nc.addObserver(self, selector: #selector(showOverlay), name: Notification.Name(rawValue: "refreshPressed"), object: nil)
        
    }
    
    private func setupNavigationBarItems() {
        
        let titleItem = navigationItem
        titleItem.title = "On the Map"
        
        let logoutButton = UIButton(type: .system)
        logoutButton.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
        logoutButton.setTitle("LOGOUT", for: .normal)
        logoutButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15)
        logoutButton.setTitleColor(UIColor(red: 81/255, green: 178/255, blue: 223/255, alpha: 1), for: .normal)
        logoutButton.frame = CGRect(x: 0, y: 0, width: 0, height: 34)
        logoutButton.sizeToFit()
        
        self.refreshButton = UIButton(type: .system)
        refreshButton!.addTarget(self, action: #selector(refreshButtonPressed), for: .touchUpInside)
        refreshButton!.setImage(#imageLiteral(resourceName: "icon_refresh").withRenderingMode(.alwaysOriginal), for: .normal)
        refreshButton!.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        let addButton = UIButton(type: .system)
        addButton.addTarget(self, action: #selector(addButtonPressed), for: .touchUpInside)
        addButton.setImage(#imageLiteral(resourceName: "icon_addpin").withRenderingMode(.alwaysOriginal), for: .normal)
        addButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: logoutButton)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: refreshButton!),UIBarButtonItem(customView: addButton)]
    }

    //MARK: Table View Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        let student = StudentsModel.sharedInstance().allStudents[indexPath.row]
        
        cell.imageView?.image = #imageLiteral(resourceName: "icon_pin")
        cell.textLabel?.text = "\(student.firstName!) \(student.lastName!)"
        cell.detailTextLabel?.text = student.mediaURL!
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentsModel.sharedInstance().allStudents.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: StudentsModel.sharedInstance().allStudents[indexPath.row].mediaURL!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
