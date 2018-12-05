//
//  PostProvider.swift
//  Course2FinalTask
//
//  Created by Вероника Данилова on 08.11.2018.
//  Copyright © 2018 e-Legion. All rights reserved.
//

import Foundation
import UIKit

final class PostsDataProvider {
    
    // Variables
    static let shared = PostsDataProvider()
    private let decoder = JSONDecoder()
    
    private lazy var defaultSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }()
    
    // Sessions
    
    public func getPostInfo(request: URLRequest?, sender: UIViewController, successCompletion: @escaping (Post) -> Void) {
        
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
                
                if let post = try? self.decoder.decode(Post.self, from: receivedData) {
                    DispatchQueue.main.async {
                        successCompletion(post)
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
    
    public func feed(request: URLRequest?, sender: UIViewController, successCompletion: @escaping ([Post]) -> Void) {
        
        guard let urlRequest = request else {
            print("Bad request")
            return
        }
        
        let dataTask = defaultSession.dataTask(with: urlRequest) { (data, response, error) in

            if let response = response as? HTTPURLResponse {
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
                if let posts = try? self.decoder.decode([Post].self, from: receivedData) {
                    DispatchQueue.main.async {
                        successCompletion(posts)
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
    

    public func usersLikePost(request: URLRequest?, sender: UIViewController, successCompletion: @escaping ([User]) -> Void) {
        
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
                if let users = try? self.decoder.decode([User].self, from: receivedData) {
                    DispatchQueue.main.async {
                        successCompletion(users)
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

    
    public func setLikeToPost(request: URLRequest?, sender: UIViewController, successCompletion: @escaping (Int) -> Void) {
        
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
                if let json = try? JSONSerialization.jsonObject(with: receivedData, options: []) as? [String: Any] {
                    let likedByCount = json!["likedByCount"] as! Int
                    DispatchQueue.main.async {
                        successCompletion(likedByCount)
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
