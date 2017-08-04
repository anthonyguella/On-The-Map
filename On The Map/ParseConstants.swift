//
//  ParseConstants.swift
//  On The Map
//
//  Created by Anthony Guella on 7/23/17.
//  Copyright © 2017 Anthony Guella. All rights reserved.
//

extension Parse {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ParseAPIKey = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"
    }
    
    // MARK: Methods
    struct Methods {
        
        static let StudentLocation = "/StudentLocation"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
        static let Where = "where"
    }
    
    //MARK: Student
    struct Student {
        let createdAt: String?
        let firstName: String?
        let lastName: String?
        let latitude: Double?
        let longitude: Double?
        let mapString: String?
        let mediaURL: String?
        let objectId: String?
        let uniqueKey: String?
        let updatedAt: String?
    }
}

extension Parse.Student {
    init?(json: [String: AnyObject]) {
        guard let createdAt = json["createdAt"] as? String,
            let firstName = json["firstName"] as? String,
            let lastName = json["lastName"] as? String,
            let latitude = json["latitude"] as? Double,
            let longitude = json["longitude"] as? Double,
            let mapString = json["mapString"] as? String,
            let mediaURL = json["mediaURL"] as? String,
            let objectId = json["objectId"] as? String,
            let uniqueKey = json["uniqueKey"] as? String,
            let updatedAt = json["updatedAt"] as? String
        else {
            return nil
        }
        
        self.createdAt = createdAt
        self.firstName = firstName
        self.lastName = lastName
        self.latitude = latitude
        self.longitude = longitude
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.updatedAt = updatedAt
    }
}
