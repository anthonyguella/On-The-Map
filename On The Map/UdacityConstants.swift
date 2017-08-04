//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Anthony Guella on 7/12/17.
//  Copyright © 2017 Anthony Guella. All rights reserved.
//

extension UdacityClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "udacity.com"
        static let ApiPath = "/api"
        static let AuthorizationURL = "https://www.udacity.com/api/session"
    }
    
    // MARK: Methods
    struct Methods {
        static let Session = "/session"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        static let Session = "session"
        static let ID = "id"
        static let Account = "account"
        static let Registered = "registered"
        static let Key = "key"
    }
}
