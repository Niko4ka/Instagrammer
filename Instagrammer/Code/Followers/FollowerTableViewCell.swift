import UIKit
import Kingfisher

class FollowerTableViewCell: UITableViewCell {
    
    public var followerID: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setFollower(_ user: User) {
        followerID = user.id

        if let userImageUrl = URL(string: user.avatar) {
            self.imageView?.kf.setImage(with: userImageUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, URL) in
                self.setNeedsLayout()
            })
        }

        self.textLabel?.text = user.fullName
    }
    
}
