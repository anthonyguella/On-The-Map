//
//  StudentsModel.swift
//  On The Map
//
//  Created by Anthony Guella on 8/4/17.
//  Copyright © 2017 Anthony Guella. All rights reserved.
//

import Foundation

class StudentsModel: NSObject {
    
    var allStudents: [Parse.Student] = [] {
        didSet {
            studentsChanged()
        }
    }
    var student: Parse.Student? = nil
    
    private func studentsChanged() {
        Parse.sharedInstance().isUpdating = false
        let nc = NotificationCenter.default
        nc.post(Notification(name: Notification.Name(rawValue: "studentsChanged")))
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> StudentsModel {
        struct Singleton {
            static var sharedInstance = StudentsModel()
        }
        return Singleton.sharedInstance
    }
    
}
