//
//  NewCollectionViewCell.swift
//  Course2FinalTask
//
//  Created by Вероника Данилова on 13.10.2018.
//  Copyright © 2018 e-Legion. All rights reserved.
//

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
