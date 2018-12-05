//
//  UsersDataProvider.swift
//  Course2FinalTask
//
//  Created by Вероника Данилова on 08.11.2018.
//  Copyright © 2018 e-Legion. All rights reserved.
//

import Foundation
import UIKit

final class UsersDataProvider {
    
    // Variables
    static let shared = UsersDataProvider()
    private let decoder = JSONDecoder()
    private var errorMessage: String!
    
    private lazy var defaultSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    // Sessions
    
    public func getUserInfo(request: URLRequest?, sender: UIViewController, successCompletion: @escaping (User) -> Void) {
        
        guard let urlRequest = request else {
            print("Bad request")
            return
        }
        
        let dataTask = defaultSession.dataTask(with: urlRequest) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse  {
                if response.statusCode == 401 {
                    DispatchQueue.main.async {
                        Alert.show401ErrorMessage(on: sender)
                    }
                } else {
                    if let errorMessage = ServerErrors.check(response: response) {
                        DispatchQueue.main.async {
                            Alert.show(message: errorMessage, on: sender)
                        }
                    }
                }
            }
            
            if let receivedData = data {
                if let user = try? self.decoder.decode(User.self, from: receivedData) {
                    DispatchQueue.main.async {
                        successCompletion(user)
                    }
                } else {
                    ServerErrors.showTransferError(on: sender)
                    return
                }
            } else {
                ServerErrors.showTransferError(on: sender)
                return
            }
        }
        
        dataTask.resume()
    }
    
    
    public func userPosts(request: URLRequest?, sender: UIViewController, successCompletion: @escaping ([Post]) -> Void) {
        
        guard let urlRequest = request else {
            print("Bad request")
            return
        }
        
        let dataTask = defaultSession.dataTask(with: urlRequest) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse  {
                if response.statusCode == 401 {
                    DispatchQueue.main.async {
                        Alert.show401ErrorMessage(on: sender)
                    }
                } else {
                    if let errorMessage = ServerErrors.check(response: response) {
                        DispatchQueue.main.async {
                            Alert.show(message: errorMessage, on: sender)
                        }
                    }
                }
            }

            if let receivedData = data {

                if let postsFromJson = try? self.decoder.decode([Post].self, from: receivedData) {
                    DispatchQueue.main.async {
                        successCompletion(postsFromJson)
                    }
                } else {
                   ServerErrors.showTransferError(on: sender)
                    return
                }
            } else {
                ServerErrors.showTransferError(on: sender)
                return
            }
        }
        dataTask.resume()
    }
    
    public func userFollowers(request: URLRequest?, sender: UIViewController, successCompletion: @escaping ([User]) -> Void) {
        
        guard let urlRequest = request else {
            print("Bad request")
            return
        }
        
        let dataTask = defaultSession.dataTask(with: urlRequest) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse  {
                if response.statusCode == 401 {
                    DispatchQueue.main.async {
                        Alert.show401ErrorMessage(on: sender)
                    }
                } else {
                    if let errorMessage = ServerErrors.check(response: response) {
                        DispatchQueue.main.async {
                            Alert.show(message: errorMessage, on: sender)
                        }
                    }
                }
            }
            
            if let receivedData = data {
                if let usersFromJson = try? self.decoder.decode([User].self, from: receivedData) {
                    DispatchQueue.main.async {
                        successCompletion(usersFromJson)
                    }
                } else {
                    ServerErrors.showTransferError(on: sender)
                    return
                }
            } else {
                ServerErrors.showTransferError(on: sender)
                return
            }
        }
        dataTask.resume()
    }
    
}
