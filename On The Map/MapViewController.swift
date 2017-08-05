//
//  MapViewController.swift
//  On The Map
//
//  Created by Anthony Guella on 7/14/17.
//  Copyright © 2017 Anthony Guella. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //MARK: Variables
    var refreshButton: UIButton?
    var overlay = LoadingOverlayView()
    
    //MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTabBarViews()
        self.addObservers()
        self.setupNavigationBarItems()
        self.adjustTabBarImage()
        self.refreshButtonPressed()
    }
    
    //MARK: Methods
    func populateMap() {
        self.mapView.removeAnnotations(mapView.annotations)
        DispatchQueue.global(qos: .userInitiated).async {
            for student in StudentsModel.sharedInstance().allStudents {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: student.latitude!, longitude: student.longitude!)
                annotation.title = "\(student.firstName!) \(student.lastName!)"
                annotation.subtitle = student.mediaURL!
                DispatchQueue.main.async {
                    self.mapView.addAnnotation(annotation)
                }
            }
            
            DispatchQueue.main.async {
                self.overlay.hideOverlayView()
                self.refreshButton!.isEnabled = true
            }
        }
    }
    
    func showOverlay() {
        refreshButton!.isEnabled = false
        overlay.showOverlay(view: self.view)
    }
    
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
                return
            }
            
            if success {
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "LoginVC")
                self.present(vc, animated: true, completion: nil)
            }
        }
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
            presentPostViewController()
        }
    }
    
    //MARK: View Setup
    private func adjustTabBarImage() {
        let tabBarItems = self.tabBarController?.tabBar.items! as! [UITabBarItem]
        for item in tabBarItems {
            item.title = nil
            item.imageInsets = UIEdgeInsetsMake(6,0,-6,0)
        }
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
    
    private func loadTabBarViews() {
        for navViewController in self.tabBarController!.viewControllers! {
            _ = navViewController.childViewControllers[0].view
        }
    }
    
    private func addObservers() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(MapViewController.populateMap), name: Notification.Name(rawValue: "studentsChanged"), object: nil)
        nc.addObserver(self, selector: #selector(MapViewController.showOverlay), name: Notification.Name(rawValue: "refreshPressed"), object: nil)
    }
    
    //MARK: MKMapViewdelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton.init(type: UIButtonType.detailDisclosure)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let url = URL(string: view.annotation!.subtitle!!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
