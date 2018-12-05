//
//  FollowerTableViewCell.swift
//  Course2FinalTask
//
//  Created by Вероника Данилова on 25.09.2018.
//  Copyright © 2018 e-Legion. All rights reserved.
//

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
