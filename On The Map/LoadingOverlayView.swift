//
//  LoadingOverlayView.swift
//  On The Map
//
//  Created by Anthony Guella on 7/30/17.
//  Copyright © 2017 Anthony Guella. All rights reserved.
//

import UIKit

class LoadingOverlayView: UIView {
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    public func showOverlay(view: UIView!) {
        overlayView = UIView(frame: UIScreen.main.bounds)
        overlayView.isUserInteractionEnabled = false
        overlayView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.center = overlayView.center
        overlayView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        view.addSubview(overlayView)
    }
    
    public func hideOverlayView() {
        activityIndicator.stopAnimating()
        overlayView.removeFromSuperview()
    }
    
}
