//
//  JSONConvenience.swift
//  On The Map
//
//  Created by Anthony Guella on 7/24/17.
//  Copyright © 2017 Anthony Guella. All rights reserved.
//

import Foundation

class NetworkConvenience {
    
    var session = URLSession.shared
    
    // MARK: Get
    func taskForGetMethod(url: URL, trimData: Bool, completionHandlerForGet: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        let request = NSMutableURLRequest(url: url)
        if url.absoluteString.contains("parse") {
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGet(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was a problem with your request: \(error!)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            var newData = data
            
            if trimData {
                let range = Range(5..<data.count)
                newData = data.subdata(in: range)
            }
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGet)
        }
        task.resume()
        return task
    }
    
    // MARK: POST
    func taskForPostMethod(url: URL, trimData: Bool, jsonBody: String, completionHandlerForPost: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        let request = NSMutableURLRequest(url: url)
        if url.absoluteString.contains("parse") {
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        request.httpMethod = "POST"
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String, _ code: Int) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPost(nil, NSError(domain: "taskForPostMethod", code: code, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was a problem with your request: \(error!)", 1)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!", 2)
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!", 2)
                return
            }
            var newData = data
            
            if trimData {
                let range = Range(5..<data.count)
                newData = data.subdata(in: range)
            }
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPost)
        }
        task.resume()
        return task
    }
    
    // MARK: PUT
    func taskForPutMethod(url: URL, trimData: Bool, jsonBody: String, completionHandlerForPut: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        let request = NSMutableURLRequest(url: url)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPut(nil, NSError(domain: "taskForPutMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was a problem with your request: \(error!)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            var newData = data
            
            if trimData {
                let range = Range(5..<data.count)
                newData = data.subdata(in: range)
            }
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPut)
        }
        task.resume()
        return task
    }
    
    // MARK: DELETE
    func taskForDeleteMethod(url: URL, trimData: Bool, completionHandlerForPost: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPost(nil, NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError("There was a problem with your request: \(error!)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            var newData = data
            
            if trimData {
                let range = Range(5..<data.count)
                newData = data.subdata(in: range)
            }
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPost)
        }
        task.resume()
        return task
    }
    
    func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> NetworkConvenience {
        struct Singleton {
            static var sharedInstance = NetworkConvenience()
        }
        return Singleton.sharedInstance
    }

}
