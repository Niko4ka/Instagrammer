import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {

    // Outlets
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followThisUserButton: UIButton!
    
    weak var delegate: ProfileViewController?
    
    @IBAction func followThisUserButtonPressed(_ sender: UIButton) {
        delegate?.followThisUserButtonPressed()
    }
    
    @IBAction func followersButtonPressed(_ sender: UIButton) {
        delegate?.followersButtonPressed()
    }
    
    @IBAction func followingButtonPressed(_ sender: UIButton) {
        delegate?.followingButtonPressed()
    }
    
}
