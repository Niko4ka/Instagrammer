import UIKit
import Kingfisher

class PostCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        postImage.frame = bounds
    }

    func setPostImage(_ post: Post) {

        if let postImageUrl = URL(string: post.image) {
            postImage.kf.setImage(with: postImageUrl)
        }
    }
    
    func setPostImage(_ post: PostEntity) {
        
        postImage.image = post.image as? UIImage
    }

}
