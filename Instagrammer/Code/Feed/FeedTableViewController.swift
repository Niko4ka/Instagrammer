//
//  FeedTableViewController.swift
//  Course2FinalTask
//
//  Created by Вероника Данилова on 12.10.2018.
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit
import Foundation
import Kingfisher

class FeedTableViewController: UITableViewController {
    
    @IBOutlet weak var feedTableView: UITableView!
 
    var posts: [Any] = []
    var userID: String = ""
    var currentPost: Post!
    var userForDestination: User?
    var usersLikedCurrentPostForDestination: [User] = []
    let decoder = JSONDecoder()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.feedTableView.register(UINib(nibName: String(describing: FeedTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: FeedTableViewCell.self))
        self.feedTableView.delegate = self
        self.feedTableView.dataSource = self
        self.feedTableView.separatorStyle = .none

        Spinner.start(from: (tabBarController?.view)!)
        
        if AuthorizationDataProvider.shared.appIsInOfflineMode {
            
            // Offline mode customization
            
            self.posts = CoreDataManager.instance.fetchData(for: PostEntity.self)
            tableView.reloadData()
            Spinner.stop()
            
        } else {
            
            // Online mode customization
            
            let feedRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.postsFeed)
            PostsDataProvider.shared.feed(request: feedRequest, sender: self) { (posts) in
                self.posts = posts
                self.feedTableView.reloadData()
                Spinner.stop()
                
                // Save data to CoreData
                
                DispatchQueue.global().async {
                    OfflineModeManager.shared.createPostStorage(from: self.posts as! [Post])
                }
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(reloadView(notification:)), name: NSNotification.Name(rawValue: "reloadView"), object: nil)
        }
        
    }
    
    @objc func reloadView(notification: NSNotification) {
        
        let reloadRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.postsFeed)
        PostsDataProvider.shared.feed(request: reloadRequest, sender: self) { (posts) in
            self.posts = posts
            self.feedTableView.reloadData()
            Spinner.stop()
            
            // Update post data in CoreData
            
            DispatchQueue.global().async {
                OfflineModeManager.shared.updatePostStorage(with: self.posts as! [Post])
            }
        }
        
        if self.posts.count > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            self.feedTableView.scrollToRow(at: indexPath, at: .top, animated: false)
            self.view.layoutIfNeeded()
        }
        
        

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = feedTableView.dequeueReusableCell(withIdentifier: String(describing: FeedTableViewCell.self), for: indexPath) as! FeedTableViewCell
        
        if AuthorizationDataProvider.shared.appIsInOfflineMode {
            cell.setPostInFeed(posts[indexPath.item] as! PostEntity)
        } else {
            cell.setPostInFeed(posts[indexPath.item] as! Post)
        }
        
        cell.feedController = self
        
        cell.showSpinnerCallback = {
            Spinner.start(from: (self.tabBarController?.view)!)
        }

        cell.addPerformSegueAction = {

            let getUserRequest = RequestService.shared.createRequest(currentCase: .usersId)
            UsersDataProvider.shared.getUserInfo(request: getUserRequest, sender: self, successCompletion: { (user) in
                
                    self.userForDestination = user
                    Spinner.stop()
                    self.performSegue(withIdentifier: "showProfile", sender: nil)
            })
        }

        cell.addUsersLikedPostSegueAction = {
            self.currentPost = cell.currentPost
            let usersLikePostRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.postsIdLikes)
            PostsDataProvider.shared.usersLikePost(request: usersLikePostRequest, sender: self, successCompletion: { (users) in
                self.usersLikedCurrentPostForDestination = users
                self.performSegue(withIdentifier: "showUsersLikedPost", sender: nil)
            })
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    // Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {


        if segue.identifier == "showProfile" {
            if let destination = segue.destination as? NewProfileViewController {
                            destination.currentUser = userForDestination
                }
        }
        if segue.identifier == "showUsersLikedPost" {
            if let destination = segue.destination as? FollowersTableViewController {
                destination.usersLikedPost = usersLikedCurrentPostForDestination
                destination.entryPoint = "usersLikedPost"
            }
        }
    }
    
    
    
}
