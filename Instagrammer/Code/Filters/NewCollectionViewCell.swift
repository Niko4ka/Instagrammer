import UIKit

class NewCollectionViewCell: UICollectionViewCell {
    
    var photoImage = UIImageView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        photoImage.frame = bounds
        self.addSubview(photoImage)
    }
    
    func setPhotoToCell(_ photo: UIImage) {
       photoImage.image = photo
    }
}
