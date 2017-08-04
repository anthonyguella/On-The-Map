//
//  Parse.swift
//  On The Map
//
//  Created by Anthony Guella on 7/23/17.
//  Copyright © 2017 Anthony Guella. All rights reserved.
//

import Foundation

class Parse: NSObject {
    
    //MARK: Variables
    var allStudents: [Parse.Student] = [] {
        didSet {
            studentsChanged()
        }
    }
    var isUpdating = false
    var student: Parse.Student? = nil
    
    // MARK: Functions
    func getStudentLocations(_ prevResults: [Student]?, completionHandler: @escaping (_ success: Bool,_ error: String?) -> Void) {
        var paramaters: [String: AnyObject]
        if prevResults != nil {
            paramaters = [Parse.ParameterKeys.Where:"{\"uniqueKey\":\"\(UdacityClient.sharedInstance().key!)\"}" as AnyObject]
        } else {
            paramaters = [ParameterKeys.Limit: 100 as AnyObject, ParameterKeys.Order: "-updatedAt" as AnyObject]
        }
        
        let url = ParseURLFromParameters(paramaters, withPathExtension: Methods.StudentLocation)
        let _ = NetworkConvenience.sharedInstance().taskForGetMethod(url: url, trimData: false) { (results, error) in
        
            guard error == nil else {
                completionHandler(false, "\(error!)")
                return
            }

        
            guard let resultsDictionary = results?["results"] as? [[String:AnyObject]] else {
                completionHandler(false, "Key 'results' not found")
                return
            }
            
            if prevResults == nil {

                var students = [Student]()
                for result in resultsDictionary {
                    if let student = Student(json: result) {
                        students.append(student)
                    }
                }
                self.getStudentLocations(students, completionHandler: completionHandler)
                
            } else {
                var students = prevResults!
                for result in resultsDictionary {
                    if let student = Student(json: result) {
                        self.student = student
                        students.append(student)
                    }
                }
                self.allStudents = students
                completionHandler(true, nil)
            }
            
        }
    }
    
    func addStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: @escaping (_ success: Bool,_ error: String?) -> Void) {
        let url = ParseURLFromParameters(nil, withPathExtension: Parse.Methods.StudentLocation)
        let client = UdacityClient.sharedInstance()
        let jsonBody = "{\"uniqueKey\": \"\(client.key!)\", \"firstName\": \"\(student!.firstName!)\", \"lastName\": \"\(student!.lastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        let _ = NetworkConvenience().taskForPostMethod(url: url, trimData: false, jsonBody: jsonBody) { (results, error) in
            
            guard error == nil else {
                completionHandler(false, "\(error)")
                return
            }
            
            completionHandler(true, nil)
    
        }
    }
    
    func updateStudentLocation(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: @escaping (_ success: Bool,_ error: String?) -> Void) {
        
        let url = ParseURLFromParameters(nil, withPathExtension: "\(Parse.Methods.StudentLocation)/\(Parse.sharedInstance().student!.objectId!)")
        let client = UdacityClient.sharedInstance()
        let jsonBody = "{\"uniqueKey\": \"\(client.key!)\", \"firstName\": \"\(student!.firstName!)\", \"lastName\": \"\(student!.lastName!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        let _ = NetworkConvenience().taskForPutMethod(url: url, trimData: false, jsonBody: jsonBody) { (results, error) in
            
            guard error == nil else {
                completionHandler(false, "\(error)")
                return
            }
            completionHandler(true, nil)
        }
    }
    
    // MARK: Helpers
    
    // Creates a URL from parameters
    private func ParseURLFromParameters(_ parameters: [String:AnyObject]?, withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Parse.Constants.ApiScheme
        components.host = Parse.Constants.ApiHost
        components.path = Parse.Constants.ApiPath + (withPathExtension ?? "")
        
        if parameters != nil {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters! {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    private func studentsChanged() {
        isUpdating = false
        let nc = NotificationCenter.default
        nc.post(Notification(name: Notification.Name(rawValue: "studentsChanged")))
        
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> Parse {
        struct Singleton {
            static var sharedInstance = Parse()
        }
        return Singleton.sharedInstance
    }
    
    
}
