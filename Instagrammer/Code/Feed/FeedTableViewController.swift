import UIKit
import Foundation
import Kingfisher

class FeedTableViewController: UITableViewController {
    
    var posts: [Any] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var userID: String = ""
    var currentPost: Post!
    let decoder = JSONDecoder()

    override func viewDidLoad() {
        super.viewDidLoad()

       tableView.register(UINib(nibName: String(describing: FeedTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: FeedTableViewCell.self))
        tableView.separatorStyle = .none

        Spinner.start(from: (tabBarController?.view)!)
        
        if AuthorizationDataProvider.shared.appIsInOfflineMode {
            
            // Offline mode customization
            
            self.posts = CoreDataManager.instance.fetchData(for: PostEntity.self)
            Spinner.stop()
            
        } else {
            
            // Online mode customization
            
            let feedRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.postsFeed)
            PostsDataProvider.shared.feed(request: feedRequest, sender: self) { (posts) in
                self.posts = posts
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
            Spinner.stop()
            
            // Update post data in CoreData
            
            DispatchQueue.global().async {
                OfflineModeManager.shared.updatePostStorage(with: self.posts as! [Post])
            }
        }
        
        if self.posts.count > 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            self.view.layoutIfNeeded()
        }

    }
    
    func showSpinnerCallback() {
        Spinner.start(from: (self.tabBarController?.view)!)
    }
    
    // MARK: - Segues
    
    func showUsersLikedPost(in cell: FeedTableViewCell) {
        self.currentPost = cell.currentPost
        let usersLikePostRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.postsIdLikes)
        PostsDataProvider.shared.usersLikePost(request: usersLikePostRequest, sender: self, successCompletion: { (users) in
            self.showUsers(users)
        })
    }

    func showProfile(of userId: String) {
        
        RequestService.shared.userId = userId
        
        let getUserRequest = RequestService.shared.createRequest(currentCase: .usersId)
        UsersDataProvider.shared.getUserInfo(request: getUserRequest, sender: self, successCompletion: { (user) in
            Spinner.stop()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let profile = storyboard.instantiateViewController(withIdentifier: "NewProfileViewController") as? NewProfileViewController {
                profile.currentUser = user
                self.navigationController?.pushViewController(profile, animated: true)
            }
        })
    }
    
    func showUsers(_ users: [User]) {
        let destination = FollowersTableViewController()
        destination.usersLikedPost = users
        destination.entryPoint = "usersLikedPost"
        navigationController?.pushViewController(destination, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FeedTableViewCell.self), for: indexPath) as! FeedTableViewCell
        cell.delegate = self
        
        if AuthorizationDataProvider.shared.appIsInOfflineMode {
            cell.setPostInFeed(posts[indexPath.item] as! PostEntity)
        } else {
            cell.setPostInFeed(posts[indexPath.item] as! Post)
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

}
