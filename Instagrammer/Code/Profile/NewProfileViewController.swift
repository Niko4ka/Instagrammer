//
//  NewProfileViewController.swift
//  Course2FinalTask
//
//  Created by Вероника Данилова on 19.10.2018.
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit
import Kingfisher

class NewProfileViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var postsCollectionView: UICollectionView!
    @IBOutlet weak var navigation: UINavigationItem!
    
    // Data transfer variables
    var currentUser: User!
    var currentUserEntity: UserEntity!
    var loggedUserID: String!
    var posts: [Post] = []
    var postsFromData = [PostEntity]()
    var viewNeedToReload = false
    var currentPostArray: [Post] = []
    var showFollowButton = false
    
    // Consts
    let itemWidth = UIScreen.main.bounds.width / 3
    let itemSpacing: CGFloat = 8.0
    let decoder = JSONDecoder()
    var logOutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Spinner.start(from: (tabBarController?.view)!)
        
        self.postsCollectionView.register(cellType: PostCollectionViewCell.self)
        self.postsCollectionView.delegate = self
        self.postsCollectionView.dataSource = self
        
        if AuthorizationDataProvider.shared.appIsInOfflineMode {
            
            // Offline mode customization
            
            guard let currentUserData = OfflineModeManager.shared.getCurrentUserData() else {
                Alert.show(message: "Unknown error", on: self)
                return
            }
            currentUserEntity = currentUserData.currentUser
            postsFromData = currentUserData.posts

            navigation.title = currentUserEntity.username
            postsCollectionView.reloadData()
            Spinner.stop()
        } else {
            getUserInfo()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        if viewNeedToReload {
            
            if currentUser.id == loggedUserID {
                let currentUserRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.usersMe)
                UsersDataProvider.shared.getUserInfo(request: currentUserRequest, sender: self) { (user) in
                    if self.currentUser.followedByCount != user.followedByCount || self.currentUser.followsCount != user.followsCount {
                        self.currentUser = user
                        self.postsCollectionView.reloadData()
                    }
                }
                self.findPosts(userId: self.currentUser.id) {
                    self.postsCollectionView.reloadData()
                }
            }
        }
    }
    
    private func getUserInfo() {
        
        // Online mode customization
        
        let currentUserRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.usersMe)
        UsersDataProvider.shared.getUserInfo(request: currentUserRequest, sender: self) { (user) in
            
            self.loggedUserID = user.id
            if self.currentUser == nil {
                self.currentUser = user
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
            
            self.findPosts(userId: self.currentUser.id, successCompletion: {
                self.showUI()
                Spinner.stop()
                self.viewNeedToReload = true
                
                if self.currentUser.id == self.loggedUserID {
                    DispatchQueue.global().async {
                        OfflineModeManager.shared.saveCurrentUser(from: self.currentUser, withPosts: self.posts)
                    }
                }
            })
        }
    }
    
    private func findPosts(userId: String, successCompletion: @escaping () -> Void) {
        RequestService.shared.userId = userId
        
        let findPostsRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.usersIdPosts)
        UsersDataProvider.shared.userPosts(request: findPostsRequest, sender: self) { (posts) in
                self.posts = posts
                successCompletion()
        }
    }
    
    private func showUI() {
        navigation.title = currentUser.username

        if currentUser.id != loggedUserID {
            showFollowButton = true
        } else {
            logOutButton = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(logOutButtonPressed(_:)))
            self.navigationItem.setRightBarButton(logOutButton, animated: false)
        }

        postsCollectionView.reloadData()
    }
    
    @objc func logOutButtonPressed(_ sender: UIBarButtonItem) {

        let tokenRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.signout)
        AuthorizationDataProvider.shared.performSignout(request: tokenRequest, sender: self) {

            Spinner.start(from: (self.tabBarController?.view)!)
            AuthorizationDataProvider.showAuthScreen()
            Spinner.stop()
        }
    }
    
    // MARK: - Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showFollowers" {
            if let destination = segue.destination as? FollowersTableViewController {
                destination.entryPoint = "followers"
                destination.currentUser = self.currentUser
            }
        }
        if segue.identifier == "showFollowing" {
            if let destination = segue.destination as? FollowersTableViewController {
                destination.entryPoint = "following"
                destination.currentUser = self.currentUser
            }
        }
    }
    
}
