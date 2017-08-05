//
//  Maps.swift
//  On The Map
//
//  Created by Anthony Guella on 8/5/17.
//  Copyright © 2017 Anthony Guella. All rights reserved.
//

import Foundation

class Maps: NSObject {
    
    func geocode(_ search: String, _ completionHandler: @escaping(_ lat: Double?, _ lng: Double?, _ adr: String?, _ error: String?) -> Void) {
        var lat: Double? = nil
        var lng: Double? = nil
        var adr: String? = nil
        
        let url = URL(string: "https://maps.google.com/maps/api/geocode/json?sensor=false&address=\(search)")!
        _ = NetworkConvenience.sharedInstance().taskForGetMethod(url: url, trimData: false) { (results, error) in
            
            guard error == nil else {
                completionHandler(nil, nil, nil, "\(error)")
                return
            }
            
            guard let results = results else {
                completionHandler(nil, nil, nil, "No results returned")
                return
            }
            
            guard let resultsArray = results["results"] as? [[String:AnyObject]] else {
                completionHandler(nil, nil, nil, "Key 'results' not found")
                return
            }
            
            for (result) in resultsArray {
                if let geometryDictionary = result["geometry"] as? [String:AnyObject], let address = result["formatted_address"] as? String, let locationDictionary = geometryDictionary["location"] as? [String:Double], let latitude = locationDictionary["lat"], let longitude = locationDictionary["lng"] {
                    lat = latitude
                    lng = longitude
                }
                if let address = result["formatted_address"] as? String {
                    adr = address
                }
            }
            
            if !(lat == nil && lng == nil && adr == nil) {
                completionHandler(lat, lng, adr, nil)
                return
            } else {
                completionHandler(nil, nil, nil, "Could Not Geocode the String")
                return
            }
        }
    }
    
    class func sharedInstance() -> Maps {
        struct Singleton {
            static var sharedInstance = Maps()
        }
        return Singleton.sharedInstance
    }
}
