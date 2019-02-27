import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let feed = storyboard.instantiateViewController(withIdentifier: "feedVC") as! FeedTableViewController
        let feedImage = UIImage(named: "feed")
        let feedNavigation = UINavigationController(rootViewController: feed)
        feedNavigation.tabBarItem = UITabBarItem(title: "Feed", image: feedImage, tag: 0)
        
        
        let newPost = storyboard.instantiateViewController(withIdentifier: "NewCollectionViewController") as! NewCollectionViewController
        let newPostImage = UIImage(named: "plus")
        let newPostNavigation = UINavigationController(rootViewController: newPost)
        newPostNavigation.tabBarItem = UITabBarItem(title: "New", image: newPostImage, tag: 1)
        
        let profile = storyboard.instantiateViewController(withIdentifier: "NewProfileViewController") as! NewProfileViewController
        let profileImage = UIImage(named: "profile")
        let profileNavigation = UINavigationController(rootViewController: profile)
        profileNavigation.tabBarItem = UITabBarItem(title: "Profile", image: profileImage, tag: 2)
        
    
        viewControllers = [feedNavigation, newPostNavigation, profileNavigation]
    }

}
