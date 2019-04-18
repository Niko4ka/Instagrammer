import UIKit
import Kingfisher

class ProfileViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var postsCollectionView: UICollectionView!
    @IBOutlet weak var navigation: UINavigationItem!
    weak var header: HeaderCollectionReusableView?
    
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
        
        postsCollectionView.register(cellType: PostCollectionViewCell.self)
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        
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
                    
                    OfflineModeManager.shared.saveCurrentUser(from: self.currentUser, withPosts: self.posts)
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
    
    // Follow/Unfollow functions
    
    func followThisUserButtonPressed() {
        
            if currentUser.currentUserFollowsThisUser {
                
                let unfollowJson = ["userID": self.currentUser.id]
                let unfollowRequest = RequestService.shared.createRequest(currentCase: .usersUnfollow, caseJson: unfollowJson)
                UsersDataProvider.shared.getUserInfo(request: unfollowRequest, sender: self, successCompletion: { (user) in
                    self.currentUser = user
                    if let header = self.header {
                        header.followThisUserButton.setTitle("Follow", for: .normal)
                        header.followThisUserButton.sizeToFit()
                        header.followersButton.setTitle("Followers: \(self.currentUser.followedByCount)", for: .normal)
                    }
                })
                
            } else {
                let followJson = ["userID": self.currentUser.id]
                let followRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.usersFollow, caseJson: followJson)
                UsersDataProvider.shared.getUserInfo(request: followRequest, sender: self, successCompletion: { (user) in
                    self.currentUser = user
                    
                    if let header = self.header {
                        header.followThisUserButton.setTitle("Unfollow", for: .normal)
                        header.followThisUserButton.sizeToFit()
                        header.followersButton.setTitle("Followers: \(self.currentUser.followedByCount)", for: .normal)
                    }
                })
            }
            
            // Update data in CoreData
            
            let currentUserRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.usersMe)
            UsersDataProvider.shared.getUserInfo(request: currentUserRequest, sender: self) { (user) in
                DispatchQueue.global().async {
                    CoreDataManager.instance.updateUser(withID: user.id, newValue: user.followedByCount, forKey: "followedByCount")
                    CoreDataManager.instance.updateUser(withID: user.id, newValue: user.followsCount, forKey: "followsCount")
                }
            }
    }
    
    func followersButtonPressed() {
        
        if AuthorizationDataProvider.shared.appIsInOfflineMode {
            Alert.showOfflineModeMessage(on: self)
        } else {
            showFollowers(of: currentUser)
        }
    }
    
    func followingButtonPressed() {
        
        if AuthorizationDataProvider.shared.appIsInOfflineMode {
            Alert.showOfflineModeMessage(on: self)
        } else {
            showFollowing(of: currentUser)
        }
    }
    
    @objc func logOutButtonPressed(_ sender: UIBarButtonItem) {

        let tokenRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.signout)
        AuthorizationDataProvider.shared.performSignout(request: tokenRequest, sender: self) {
            Spinner.start(from: (self.tabBarController?.view)!)
            AuthorizationDataProvider.showAuthScreen()
            Spinner.stop()
        }
    }

    private func showFollowers(of user: User) {
        let followers = FollowersTableViewController(listType: .followers, currentUser: user)
        navigationController?.pushViewController(followers, animated: true)
    }
    
    private func showFollowing(of user: User) {
        let following = FollowersTableViewController(listType: .following, currentUser: user)
        navigationController?.pushViewController(following, animated: true)
    }
    
}
