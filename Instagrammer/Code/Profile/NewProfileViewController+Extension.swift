//
//  NewProfileViewController+Extension.swift
//  Instagrammer
//
//  Created by Вероника Данилова on 04/12/2018.
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit

// MARK: - UICollectionViewDataSource

extension NewProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        if AuthorizationDataProvider.shared.appIsInOfflineMode {
            return postsFromData.count
        } else {
            return posts.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = postsCollectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "profileHeader", for: indexPath) as! HeaderCollectionReusableView
        
        if AuthorizationDataProvider.shared.appIsInOfflineMode {
            
            header.followThisUserButton.isHidden = true
            header.avatarImage.image = currentUserEntity.avatar as? UIImage
            header.avatarImage.layer.cornerRadius = header.avatarImage.frame.size.width / 2
            header.avatarImage.layer.masksToBounds = true
            
            header.fullnameLabel.text = currentUserEntity.fullname
            header.fullnameLabel.sizeToFit()
            
            header.followersButton.setTitle("Followers: \(currentUserEntity.followedByCount)", for: .normal)
            header.followersButton.sizeToFit()
            
            header.followingButton.setTitle("Following: \(currentUserEntity.followsCount)", for: .normal)
            header.followingButton.sizeToFit()
            
        } else {
            if currentUser != nil {
                header.followThisUserButton.isHidden = true
                
                if let avatarImageUrl = URL(string: currentUser.avatar) {
                    header.avatarImage.kf.setImage(with: avatarImageUrl)
                }
                
                header.avatarImage.layer.cornerRadius = header.avatarImage.frame.size.width / 2
                header.avatarImage.layer.masksToBounds = true
                
                header.fullnameLabel.text = currentUser.fullName
                header.fullnameLabel.sizeToFit()
                
                header.followersButton.setTitle("Followers: \(currentUser.followedByCount)", for: .normal)
                header.followersButton.sizeToFit()
                
                header.followingButton.setTitle("Following: \(currentUser.followsCount)", for: .normal)
                header.followingButton.sizeToFit()
                
                if showFollowButton {
                    header.followThisUserButton.layer.cornerRadius = 5.0
                    header.followThisUserButton.isHidden = false
                    
                    if currentUser.currentUserFollowsThisUser {
                        header.followThisUserButton.setTitle("Unfollow", for: .normal)
                        header.followThisUserButton.sizeToFit()
                    } else {
                        header.followThisUserButton.setTitle("Follow", for: .normal)
                        header.followThisUserButton.sizeToFit()
                    }
                }
            }
        }
        
        header.followersButtonPressed = {
            if AuthorizationDataProvider.shared.appIsInOfflineMode {
                Alert.showOfflineModeMessage(on: self)
            } else {
                self.performSegue(withIdentifier: "showFollowers", sender: nil)
            }
        }
        
        header.followingButtonPressed = {
            if AuthorizationDataProvider.shared.appIsInOfflineMode {
                Alert.showOfflineModeMessage(on: self)
            } else {
                self.performSegue(withIdentifier: "showFollowing", sender: nil)
            }
        }
        
        header.followThisUserButtonPressed = {
            
            if self.currentUser.currentUserFollowsThisUser {
                
                let unfollowJson = ["userID": self.currentUser.id]
                let unfollowRequest = RequestService.shared.createRequest(currentCase: .usersUnfollow, caseJson: unfollowJson)
                UsersDataProvider.shared.getUserInfo(request: unfollowRequest, sender: self, successCompletion: { (user) in
                    self.currentUser = user
                    header.followThisUserButton.setTitle("Follow", for: .normal)
                    header.followThisUserButton.sizeToFit()
                    header.followersButton.setTitle("Followers: \(self.currentUser.followedByCount)", for: .normal)
                })
                
            } else {
                let followJson = ["userID": self.currentUser.id]
                let followRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.usersFollow, caseJson: followJson)
                UsersDataProvider.shared.getUserInfo(request: followRequest, sender: self, successCompletion: { (user) in
                    self.currentUser = user
                    header.followThisUserButton.setTitle("Unfollow", for: .normal)
                    header.followThisUserButton.sizeToFit()
                    header.followersButton.setTitle("Followers: \(self.currentUser.followedByCount)", for: .normal)
                })
            }
            
            // Update data in CoreData
            
            let currentUserRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.usersMe)
            UsersDataProvider.shared.getUserInfo(request: currentUserRequest, sender: self) { (user) in
                DispatchQueue.global().async {
                    CoreDataManager.instance.updateUser(withID: user.id, newValue: user.followedByCount, forKey: "followedByCount")
                    CoreDataManager.instance.updateUser(withID: user.id, newValue: user.followsCount, forKey: "followsCount")
                }
            }
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = postsCollectionView.dequeueCell(of: PostCollectionViewCell.self, for: indexPath)
        
        if AuthorizationDataProvider.shared.appIsInOfflineMode {
            cell.setPostImage(postsFromData[indexPath.item])
        } else {
            cell.setPostImage(posts[indexPath.item])
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension NewProfileViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        postsCollectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NewProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemHeight = itemWidth
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,
                            left: 0,
                            bottom: 0,
                            right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: 86.0)
    }
    
}


