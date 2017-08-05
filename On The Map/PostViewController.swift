//
//  PostViewController.swift
//  On The Map
//
//  Created by Anthony Guella on 7/30/17.
//  Copyright © 2017 Anthony Guella. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        self.tabBarController?.tabBar.isHidden = true
        self.setupNavBar()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        dismissKeyboard()
    }
    
    //MARK: IBActions
    @IBAction func findLocationButton(_ sender: Any) {
        
        if locationTextField.text!.isEmpty {
            alertView("Must Enter a Location.")
        }
        else if websiteTextField.text!.isEmpty {
            alertView("Must Enter a Website.")
        }
        let valid = validURL(websiteTextField.text!)
        if !valid {
            alertView("Invalid Link. Include HTTP(S)://.")
        } else {
            self.searchForLocation()
        }
    }
    
    //MARK: Methods
    private func searchForLocation() {
        
        var lat: Double?
        var lng: Double?
        var adr: String?
        
        let search = locationTextField.text!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        print(search)
        let url = URL(string: "https://maps.google.com/maps/api/geocode/json?sensor=false&address=\(search)")!
        _ = NetworkConvenience.sharedInstance().taskForGetMethod(url: url, trimData: false) { (results, error) in
            
            guard error == nil else {
                return
            }
            
            guard let results = results else {
                return
            }
            
            guard let resultsArray = results["results"] as? [[String:AnyObject]] else {
                print("error")
                return
            }
            
            for (result) in resultsArray {
                if let geometryDictionary = result["geometry"] as? [String:AnyObject], let locationDictionary = geometryDictionary["location"] as? [String:Double], let latitude = locationDictionary["lat"], let longitude = locationDictionary["lng"] {
                    lat = latitude
                    lng = longitude
                }
                if let address = result["formatted_address"] as? String {
                    adr = address
                }
            }
            
            if !(lat == nil && lng == nil && adr == nil) {
                self.presentLocationConfirmationViewController(lng: lng!, lat: lat!, adr: adr!)
                return
            } else {
                self.alertView("Could Not Geocode the String")
                return
            }
        }
    }
    
    //MARK: Helper Methods
    private func validURL(_ url: String) -> Bool {
        let url = url.lowercased()
        if url.hasPrefix("http://") {
            return true
        }
        else if url.hasPrefix("https://") {
            return true
        }
        return false
    }
    
    private func alertView(_ message: String) {
        let alertController = UIAlertController(title: "Location Not Found", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "DISMISS", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func popView() {
        self.navigationController?.popViewController(animated: true)
        tabBarController?.tabBar.isHidden = false
    }
    
    private func presentLocationConfirmationViewController (lng: Double, lat: Double, adr: String) {
        DispatchQueue.main.async {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "LocationConfirmViewController") as! LocationConfirmViewController
            vc.mediaURL = self.websiteTextField.text!
            vc.lat = lat
            vc.lng = lng
            vc.adr = adr
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: View Setup
    private func setupNavBar() {
        self.navigationItem.title = "Add Location"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(popView))
    }
}
