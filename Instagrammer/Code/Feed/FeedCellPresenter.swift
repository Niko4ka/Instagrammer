import UIKit

protocol FeedTableViewCellPresenter: class {
    
    var cell: FeedTableViewCell { get set }
    
    func likePost()
    func unlikePost()
}

class FeedCellPresenter: FeedTableViewCellPresenter {
    
    unowned var cell: FeedTableViewCell
    
    init(for cell: FeedTableViewCell) {
        self.cell = cell
    }
    
    
    func likePost() {
        guard let delegate = cell.delegate else { return }
        
        let postIdJson = ["postID" : cell.postID]
        
        let likePostRequest = RequestService.shared.createRequest(currentCase: .postsLike, caseJson: postIdJson as [String : Any])
        PostsDataProvider.shared.setLikeToPost(request: likePostRequest, sender: delegate) { likedByCount in
            self.cell.numberOfLikesButton.setTitle("Likes: \(likedByCount)", for: .normal)
            self.cell.likeButton.tintColor = self.cell.defaultButtonColor
            self.cell.currentUserLikesThisPost = true
            self.updateLikeStatusInCoreData(likedByCount: likedByCount)
        }
    }
    
    func unlikePost() {
        
        guard let delegate = cell.delegate else { return }
        
        let postIdJson = ["postID" : cell.postID]
        
        let unlikePostRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.postsUnlike, caseJson: postIdJson as [String : Any])
        PostsDataProvider.shared.setLikeToPost(request: unlikePostRequest, sender: delegate) { likedByCount in
            self.cell.numberOfLikesButton.setTitle("Likes: \(likedByCount)", for: .normal)
            self.cell.likeButton.tintColor = UIColor.lightGray
            self.cell.currentUserLikesThisPost = false
            self.updateLikeStatusInCoreData(likedByCount: likedByCount)
        }
        
    }
    
    private func updateLikeStatusInCoreData(likedByCount: Int) {
        DispatchQueue.global().async {
            CoreDataManager.instance.updatePost(withID: self.cell.postID, newIntValue: likedByCount, forKey: "likedByCount")
            CoreDataManager.instance.updatePost(withID: self.cell.postID, newValue: self.cell.currentUserLikesThisPost, forKey: "currentUserLikesThisPost")
        }
    }
    
}
