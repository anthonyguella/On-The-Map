//
//  LoginViewController.swift
//  On The Map
//
//  Created by Anthony Guella on 7/12/17.
//  Copyright © 2017 Anthony Guella. All rights reserved.
//

import UIKit

class LoginViewController : UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    //MARK: Methods
    private func completeLogin() {
        let controller = storyboard!.instantiateViewController(withIdentifier: "mainTabController") as! UITabBarController
        present(controller, animated: true, completion: nil)
    }
    
    //MARK: IBActions
    @IBAction func loginPressed(_ sender: Any) {
        guard let username = emailTextField.text, !username.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            self.displayError(message: "Username/Password Field Is Blank.")
            return
        }
        
        activityIndicator.startAnimating()
        UdacityClient.sharedInstance().username = username
        UdacityClient.sharedInstance().password = password
            
        DispatchQueue.global(qos: .userInitiated).async {
                
            UdacityClient.sharedInstance().authenticate(completionHandlerForAuth: { (success, error) in
                    
                if success {
                    self.completeLogin()
                    self.activityIndicator.stopAnimating()
                }
                else {
                    DispatchQueue.main.async {
                        self.displayError(message: error!)
                        self.activityIndicator.stopAnimating()
                    }
                }
            })
        }
    }

    //MARK: Helper Functions
    private func displayError(message: String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
