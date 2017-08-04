//
//  LocationConfirmViewController.swift
//  On The Map
//
//  Created by Anthony Guella on 7/31/17.
//  Copyright © 2017 Anthony Guella. All rights reserved.
//

import UIKit
import MapKit

class LocationConfirmViewController: UIViewController {
    
    //MARK: Variables
    var mediaURL: String?
    var lng: Double?
    var lat: Double?
    var adr: String?
    
    //MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Add Location"
        setupMap()
    }
    
    //MARK: Methods
    private func setupMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
        annotation.title = adr!
        self.mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpanMake(0.1, 0.1))
        self.mapView.setRegion(region, animated: true)
    }
    private func alertView(_ message: String) {
        let alertController = UIAlertController(title: "Location Not Found", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "DISMISS", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func popToRoot() {
        self.tabBarController?.tabBar.isHidden = false
        if let vc = self.navigationController!.viewControllers[0] as? MapViewController {
            DispatchQueue.main.async {
                self.navigationController!.popToRootViewController(animated: true)
                vc.refreshButtonPressed()
            }
        } else {
            let vc = self.navigationController!.viewControllers[0] as! StudentTableViewController
            DispatchQueue.main.async {
                self.navigationController!.popToRootViewController(animated: true)
                vc.refreshButtonPressed()
            }
        }
    }
    
    //MARK: IBActions
    @IBAction func finishButtonPressed(_ sender: Any) {
        if Parse.sharedInstance().student != nil {
            Parse.sharedInstance().updateStudentLocation(mapString: adr!, mediaURL: mediaURL!, latitude: lat!, longitude: lng!, completionHandler: { (success, error) in
                guard error == nil else {
                    self.alertView("Failed to Update Location")
                    return
                }
                
                self.popToRoot()
                
            })
        } else {
            Parse.sharedInstance().addStudentLocation(mapString: adr!, mediaURL: mediaURL!, latitude: lat!, longitude: lng!, completionHandler: { (success, error) in
                guard error == nil else {
                    self.alertView("Failed to Update Location")
                    return
                }
                self.popToRoot()
            })
        }
    }
}
