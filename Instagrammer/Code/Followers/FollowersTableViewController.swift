import UIKit

enum UsersListType {
    case followers
    case following
    case usersLikedPost
}

class FollowersTableViewController: UITableViewController {
    
    var users: [User] = []
    var listType: UsersListType
    var currentUser: User? {
        didSet {
            configureList()
        }
    }
    
    init(listType: UsersListType) {
        self.listType = listType
        super.init(style: .plain)
    }
    
    convenience init(listType: UsersListType, currentUser: User) {
        self.init(listType: listType)
        self.currentUser = currentUser
    }
    
    convenience init(listType: UsersListType, users: [User]) {
        self.init(listType: listType)
        self.users = users
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Spinner.start(from: (tabBarController?.view)!)
        tableView.register(UINib(nibName: String(describing: FollowerTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: FollowerTableViewCell.self))
        guard currentUser != nil else {
            setCurrentUser()
            return
        }
        configureList()
    }
    
    // MARK: - Private
    
    private func configureList() {
        switch listType {
        case .followers: setFollowers()
        case .following: setFollowing()
        case .usersLikedPost:
            navigationItem.title = "Likes"
            tableView.reloadData()
            Spinner.stop()
        }
    }
    
    private func setCurrentUser() {
        let currentUserRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.usersMe)
        UsersDataProvider.shared.getUserInfo(request: currentUserRequest, sender: self) { [weak self] (user) in
            self?.currentUser = user
        }
    }
    
    private func setFollowers() {
        RequestService.shared.userId = self.currentUser?.id
        let followersRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.usersIdFollowers)
        UsersDataProvider.shared.userFollowers(request: followersRequest, sender: self) { [weak self] (users) in
            self?.users = users
            self?.navigationItem.title = "Followers"
            self?.tableView.reloadData()
            Spinner.stop()
        }
    }
    
    private func setFollowing() {
        RequestService.shared.userId = self.currentUser?.id
        let followingRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.usersIdFollowing)
        UsersDataProvider.shared.userFollowers(request: followingRequest, sender: self) { [weak self] (users) in
            self?.users = users
            self?.navigationItem.title = "Following"
            self?.tableView.reloadData()
            Spinner.stop()
        }
    }
    
    private func showProfile(of follower: User) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let profile = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            profile.currentUser = follower
            navigationController?.pushViewController(profile, animated: true)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FollowerTableViewCell.self), for: indexPath) as! FollowerTableViewCell
        cell.setFollower(users[indexPath.row])
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
        UsersDataProvider.shared.getUserInfo(request: followerRequest, sender: self) { [weak self] (user) in
            Spinner.stop()
            self?.showProfile(of: user)
        }
    }
    
}
