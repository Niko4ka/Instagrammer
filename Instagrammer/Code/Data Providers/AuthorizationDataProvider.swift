//
//  AuthorizationDataProvider.swift
//  Course2FinalTask
//
//  Created by Вероника Данилова on 08.11.2018.
//  Copyright © 2018 e-Legion. All rights reserved.
//

import Foundation
import UIKit

final class AuthorizationDataProvider {
    
    // Variables
    static let shared = AuthorizationDataProvider()
    
    public var appIsInOfflineMode = false
    
    private lazy var defaultSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    // Sessions
    
    public func performSignin(request: URLRequest?, sender: UIViewController, successCompletion: @escaping (String) -> Void) {
        
        guard let urlRequest = request else {
            print("Bad request")
            return
        }
        
        let dataTask = defaultSession.dataTask(with: urlRequest) { (data, response, error) in

            if let response = response as? HTTPURLResponse  {
                if let errorMessage = ServerErrors.check(response: response) {
                    DispatchQueue.main.async {
                        Alert.show(message: errorMessage, on: sender)
                        Spinner.stop()
                    }
                }
            }
            
            if let receivedData = data {
                guard let responseJson = try? JSONSerialization.jsonObject(with: receivedData, options: []) as? [String: Any] else {
                    ServerErrors.showTransferError(on: sender)
                    return
                }
                
                guard let token = responseJson!["token"] as? String else { return }
                
                DispatchQueue.main.async {
                    successCompletion(token)
                }
            } else {
                ServerErrors.showTransferError(on: sender)
                return
            }
 
        }
        
        dataTask.resume()
    }
    
    public func performSignout(request: URLRequest?, sender: UIViewController, successCompletion: @escaping () -> Void) {

        guard let urlRequest = request else {
            print("Bad request")
            return
        }
        
        let dataTask = defaultSession.dataTask(with: urlRequest) { (data, response, error) in
            if let response = response as? HTTPURLResponse  {
                if let errorMessage = ServerErrors.check(response: response) {
                    DispatchQueue.main.async {
                        Alert.show(message: errorMessage, on: sender)
                    }
                } else {
                    DispatchQueue.main.async {
                        successCompletion()
                    }
                }
            }

        }
        dataTask.resume()
    }
    
    public func checkToken(request: URLRequest?, successCompletion: @escaping () -> Void, offlineModeCompletion: @escaping () -> Void) {
        
        print("checkToken")
        
        guard let urlRequest = request else {
            print("Bad request")
            return
        }
        
        let dataTask = defaultSession.dataTask(with: urlRequest) { (data, response, error) in
            
            if let error = error {
                print("Error - \(error.localizedDescription)")
                self.appIsInOfflineMode = true
                offlineModeCompletion()
            }
            
            if let response = response as? HTTPURLResponse {
                print("Response of check token - \(response.statusCode)")
                if response.statusCode == 200 {
                    DispatchQueue.main.async {
                        successCompletion()
                    }
                } else if response.statusCode == 401 {
                    DispatchQueue.main.async {
                        print("token is invalid")
                        KeychainService.shared.deleteToken()
                        Spinner.stop()
                    }
                } else {
                    self.appIsInOfflineMode = true
                    offlineModeCompletion()
                }
            }
        }
        dataTask.resume()
    }
    
    public static func showAuthScreen() {
        
        KeychainService.shared.deleteToken()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "authVC") as! AuthViewController
        UIApplication.shared.keyWindow?.rootViewController = initialViewController
    }
    
}
