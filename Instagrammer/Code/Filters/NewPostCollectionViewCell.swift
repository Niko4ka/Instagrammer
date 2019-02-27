import UIKit

class NewPostCollectionViewCell: UICollectionViewCell {
    
    var photoImage = UIImageView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photoImage.frame = bounds
        self.addSubview(photoImage)
    }
    
    func configureCellWith(_ photo: UIImage) {
       photoImage.image = photo
    }
}
