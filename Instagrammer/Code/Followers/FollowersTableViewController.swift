import UIKit

class FollowersTableViewController: UITableViewController {
    
    var followers: [User] = []
    var following: [User] = []
    var usersLikedPost: [User] = []
    var entryPoint: String!
    var followerID: String!
    var currentUser: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Spinner.start(from: (tabBarController?.view)!)
        
        tableView.register(UINib(nibName: String(describing: FollowerTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: FollowerTableViewCell.self))
        
        if entryPoint == "usersLikedPost" {
            navigationItem.title = "Likes"
            tableView.reloadData()
            Spinner.stop()
        }
        
        if currentUser == nil {
            let currentUserRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.usersMe)
            UsersDataProvider.shared.getUserInfo(request: currentUserRequest, sender: self) { (user) in
                self.currentUser = user
            }
        }

            switch self.entryPoint {
            case "followers":
                RequestService.shared.userId = self.currentUser?.id
                let followersRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.usersIdFollowers)
                UsersDataProvider.shared.userFollowers(request: followersRequest, sender: self) { (users) in
                    self.followers = users
                    self.navigationItem.title = "Followers"
                    self.tableView.reloadData()
                    Spinner.stop()
                }

            case "following":
                
                RequestService.shared.userId = self.currentUser?.id
                let followingRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.usersIdFollowing)
                UsersDataProvider.shared.userFollowers(request: followingRequest, sender: self) { (users) in
                    self.following = users
                    self.navigationItem.title = "Following"
                    self.tableView.reloadData()
                    Spinner.stop()
                }

            default:
                ()
            }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch entryPoint {
        case "followers":
            return followers.count
        case "following":
            return following.count
        case "usersLikedPost":
            return usersLikedPost.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FollowerTableViewCell.self), for: indexPath) as! FollowerTableViewCell

        switch entryPoint {
        case "followers":
            cell.setFollower(followers[indexPath.row])
        case "following":
            cell.setFollower(following[indexPath.row])
        case "usersLikedPost":
            cell.setFollower(usersLikedPost[indexPath.row])
        default:
            ()
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        Spinner.start(from: (tabBarController?.view)!)

        let cell = tableView.cellForRow(at: indexPath) as? FollowerTableViewCell
        RequestService.shared.userId = cell?.followerID
        let followerRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.usersId)
        UsersDataProvider.shared.getUserInfo(request: followerRequest, sender: self) { (user) in
            Spinner.stop()
            self.showProfile(of: user)
        }
    }
    
    func showProfile(of follower: User) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let profile = storyboard.instantiateViewController(withIdentifier: "NewProfileViewController") as? NewProfileViewController {
            profile.currentUser = follower
            navigationController?.pushViewController(profile, animated: true)
        }
        
    }
    
}
