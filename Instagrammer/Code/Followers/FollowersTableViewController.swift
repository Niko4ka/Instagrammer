import UIKit

class FollowersTableViewController: UITableViewController {
    
    @IBOutlet var followersTableView: UITableView!

    var followers: [User] = []
    var following: [User] = []
    var usersLikedPost: [User] = []
    var entryPoint: String!
    var followerID: String!
    var currentUser: User?
    var userForDestination: User?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Spinner.start(from: (tabBarController?.view)!)
        
        self.followersTableView.register(UINib(nibName: String(describing: FollowerTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: FollowerTableViewCell.self))
        self.followersTableView.delegate = self
        self.followersTableView.dataSource = self
        
        if entryPoint == "usersLikedPost" {
            self.navigationItem.title = "Likes"
            self.followersTableView.reloadData()
            Spinner.stop()
        }
        
        if self.currentUser == nil {
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
                    self.followersTableView.reloadData()
                    Spinner.stop()
                }

            case "following":
                
                RequestService.shared.userId = self.currentUser?.id
                let followingRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.usersIdFollowing)
                UsersDataProvider.shared.userFollowers(request: followingRequest, sender: self) { (users) in
                    self.following = users
                    self.navigationItem.title = "Following"
                    self.followersTableView.reloadData()
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
            self.userForDestination = user
            Spinner.stop()
            self.performSegue(withIdentifier: "showFollowerProfile", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFollowerProfile" {
            if let destination = segue.destination as? NewProfileViewController {
                destination.currentUser = userForDestination
            }
        }
    }
    
}
