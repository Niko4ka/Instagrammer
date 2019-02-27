import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {

    // Outlets
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followThisUserButton: UIButton!
    
    var followThisUserButtonPressed: (()->())?
    var followersButtonPressed: (()->())?
    var followingButtonPressed: (()->())?
    
    @IBAction func followThisUserButtonPressed(_ sender: UIButton) {
        followThisUserButtonPressed?()
    }
    
    @IBAction func followersButtonPressed(_ sender: UIButton) {
        followersButtonPressed?()
    }
    
    @IBAction func followingButtonPressed(_ sender: UIButton) {
        followingButtonPressed?()
    }
    
}
