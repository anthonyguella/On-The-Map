//
//  UdacityClient.swift
//  On The Map
//
//  Created by Anthony Guella on 7/12/17.
//  Copyright © 2017 Anthony Guella. All rights reserved.
//

import Foundation

class UdacityClient : NSObject {
    
    // MARK: Properties
    var session = URLSession.shared
    var sessionID: String? = nil
    var username: String? = nil
    var password: String? = nil
    var key: String? = nil
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    // MARK: Functions
    func authenticate(completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        getSessionID { (success, sessionID, key, error) in
            if success {
                self.sessionID = sessionID
                self.key = key
                completionHandlerForAuth(true, nil)
            } else {
                completionHandlerForAuth(false, error)
            }
        }
    }
    
    func getSessionID (completionHandlerForSession: @escaping (_ success: Bool, _ sessionID: String?, _ key: String?, _ errorString: String?) -> Void) {
        let jsonBody = "{\"udacity\": {\"username\": \"\(self.username!)\", \"password\": \"\(self.password!)\"}}"
        let url = URL(string: Constants.AuthorizationURL)!
        let _ = NetworkConvenience.sharedInstance().taskForPostMethod(url: url, trimData: true, jsonBody: jsonBody) { (results, error) in

            guard error == nil else {
                if error!.code == 1 {
                    completionHandlerForSession(false, nil, nil, "Unable to Connect to Server" )
                } else {
                    completionHandlerForSession(false, nil, nil, "Invalid Email or Password")
                }
                return
            }
            
            guard let accountDictionary = results?[JSONResponseKeys.Account] as? [String:AnyObject], let registered = accountDictionary[JSONResponseKeys.Registered] as? Bool else {
                completionHandlerForSession(false, nil, nil, "JSON key: \(JSONResponseKeys.Account) not found")
                return
            }
            
            if registered == true {
                guard let sessionDictionary = results?[JSONResponseKeys.Session] as? [String:AnyObject], let sessionID = sessionDictionary[JSONResponseKeys.ID] as? String, let key = accountDictionary[JSONResponseKeys.Key] as? String else {
                    completionHandlerForSession(false, nil, nil, "JSON key: \(JSONResponseKeys.Session) not found")
                    return
                }
                completionHandlerForSession(true, sessionID, key, nil)
            } else {
                completionHandlerForSession(false, nil, nil, "Invalid Email or Password")
            }
        }
    }
    
    func logout(completionHandlerForLogout: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let url = URL(string: Constants.AuthorizationURL)!
        let _ = NetworkConvenience.sharedInstance().taskForDeleteMethod(url: url, trimData: true) { (results, error) in
            
            guard (error == nil) else {
                completionHandlerForLogout(false, "\(error!)")
                return
            }
            completionHandlerForLogout(true,nil)
        }
    }
    
    // MARK: Helpers
    
    // Creates a URL from parameters
    private func UdacityURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()

        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }

        return components.url!
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}
