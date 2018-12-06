//
//  Spinner.swift
//  Course2FinalTask
//
//  Created by Вероника Данилова on 14.10.2018.
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit

final class Spinner {
    
    fileprivate static var activityIndicator: UIActivityIndicatorView?
    fileprivate static var style: UIActivityIndicatorView.Style = .white
    fileprivate static var backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)

    public static func start(from view: UIView) {
        
        let frame = UIScreen.main.bounds
        guard Spinner.activityIndicator == nil else { return }
        let spinner = UIActivityIndicatorView(frame: frame)
        spinner.style = .white
        spinner.backgroundColor = backgroundColor
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        addConstraints(to: view, with: spinner)
        
        Spinner.activityIndicator = spinner
        Spinner.activityIndicator?.startAnimating()
    }
    
    public func filterLoading(on view: UIView) {
        
        let frame = view.bounds
        guard Spinner.activityIndicator == nil else { return }
        let spinner = UIActivityIndicatorView(frame: frame)
        spinner.style = .white
        spinner.backgroundColor = Spinner.backgroundColor
        spinner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinner)
        
        Spinner.addConstraints(to: view, with: spinner)
        
        Spinner.activityIndicator = spinner
        Spinner.activityIndicator?.startAnimating()
    }
    
    public static func stop() {
        Spinner.activityIndicator?.stopAnimating()
        Spinner.activityIndicator?.removeFromSuperview()
        Spinner.activityIndicator = nil
    }
    
    fileprivate static func addConstraints(to view: UIView, with spinner: UIActivityIndicatorView) {
        spinner.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        spinner.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        spinner.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        spinner.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
    
}
