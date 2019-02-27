import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let feed = FeedTableViewController()
        let feedImage = UIImage(named: "feed")
        let feedNavigation = UINavigationController(rootViewController: feed)
        feedNavigation.tabBarItem = UITabBarItem(title: "Feed", image: feedImage, tag: 0)
        
        let newPost = storyboard.instantiateViewController(withIdentifier: "NewPostCollectionViewController") as! NewPostCollectionViewController
        let newPostImage = UIImage(named: "plus")
        let newPostNavigation = UINavigationController(rootViewController: newPost)
        newPostNavigation.tabBarItem = UITabBarItem(title: "New", image: newPostImage, tag: 1)
        
        let profile = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        let profileImage = UIImage(named: "profile")
        let profileNavigation = UINavigationController(rootViewController: profile)
        profileNavigation.tabBarItem = UITabBarItem(title: "Profile", image: profileImage, tag: 2)
        
    
        viewControllers = [feedNavigation, newPostNavigation, profileNavigation]
    }

}
