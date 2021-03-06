import UIKit
import Kingfisher

class FeedTableViewCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var publishTimeLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var numberOfLikesButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bigLikeImage: UIImageView!

    // Data transfer variables
    var postID: String!
    var currentUserLikesThisPost: Bool!
    var currentPost: Post!
    var avatarUserId: String!

    weak var delegate: FeedTableViewController?
    var presenter: FeedTableViewCellPresenter!
    let defaultButtonColor = UIButton(type: UIButton.ButtonType.system).titleColor(for: .normal)
    
    // MARK: - Like / Dislike operations
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        
        if AuthorizationDataProvider.shared.appIsInOfflineMode {
            if let delegate = delegate {
                Alert.showOfflineModeMessage(on: delegate)
            }
        } else {
            if currentUserLikesThisPost {
                presenter.unlikePost()
            } else {
                presenter.likePost()
            }
        }
    }

    @objc func showBigLikeImage() {
        
        guard let delegate = delegate else { return }

        if AuthorizationDataProvider.shared.appIsInOfflineMode {
            Alert.showOfflineModeMessage(on: delegate)
        } else {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveLinear], animations: {
                self.bigLikeImage.alpha = 1.0
            }, completion: {_ in
                UIView.animate(withDuration: 0.3, delay: 0.2, options: [.curveEaseOut], animations: {
                    self.bigLikeImage.alpha = 0
                }, completion: nil)
            })
            
            if currentUserLikesThisPost {
                presenter.unlikePost()
            } else {
                presenter.likePost()
            }
        }

    }
    
    // MARK: - Basic
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        presenter = FeedCellPresenter(for: self)
        
        postImage.isUserInteractionEnabled = true
        avatarImage.isUserInteractionEnabled = true
        usernameLabel.isUserInteractionEnabled = true
        publishTimeLabel.isUserInteractionEnabled = true
        
        // Adding tapGestureRecognizers
        
        addTapGestureRecognizerForPostImage()
        avatarImage.addGestureRecognizer(addTapGestureRecognizerForUser())
        usernameLabel.addGestureRecognizer(addTapGestureRecognizerForUser())
        publishTimeLabel.addGestureRecognizer(addTapGestureRecognizerForUser())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        usernameLabel.sizeToFit()
        publishTimeLabel.sizeToFit()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    // MARK: - Data providing
    
    func setPostInFeed(_ post: Post) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z"
        if let date = formatter.date(from: post.createdTime) {
            formatter.timeStyle = .medium
            formatter.dateStyle = .medium
            publishTimeLabel.text = "\(formatter.string(from: date))"
        } else {
            publishTimeLabel.text = ""
        }
        
        postID = post.id
        currentUserLikesThisPost = post.currentUserLikesThisPost
        
        if let avatarImageUrl = URL(string: post.authorAvatar) {
            avatarImage.kf.setImage(with: avatarImageUrl)
        }
        
        if let postImageUrl = URL(string: post.image) {
            postImage.kf.setImage(with: postImageUrl)
        }
        
        usernameLabel.text = post.authorUsername

        numberOfLikesButton.setTitle("Likes: \(post.likedByCount)", for: .normal)
        descriptionLabel.text = post.description
        
        if (post.currentUserLikesThisPost!) {
            likeButton.tintColor = defaultButtonColor
        } else {
            likeButton.tintColor = UIColor.lightGray
        }
        
    }
    
    func setPostInFeed(_ post: PostEntity) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z"
        if let date = formatter.date(from: post.createdTime!) {
            formatter.timeStyle = .medium
            formatter.dateStyle = .medium
            publishTimeLabel.text = "\(formatter.string(from: date))"
        } else {
            publishTimeLabel.text = ""
        }
        
        postID = post.id
        currentUserLikesThisPost = post.currentUserLikesThisPost
        
        avatarImage.image = post.authorAvatar as? UIImage
        postImage.image = post.image as? UIImage
        
        usernameLabel.text = post.authorUsername
        
        numberOfLikesButton.setTitle("Likes: \(post.likedByCount)", for: .normal)
        descriptionLabel.text = post.desc
        
        if post.currentUserLikesThisPost {
            likeButton.tintColor = defaultButtonColor
        } else {
            likeButton.tintColor = UIColor.lightGray
        }
        
    }
    
    // MARK: - Gesture recognizers
    
    func addTapGestureRecognizerForPostImage() {

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showBigLikeImage))
        tapGestureRecognizer.numberOfTapsRequired = 2
        postImage.addGestureRecognizer(tapGestureRecognizer)
    }

    func addTapGestureRecognizerForUser() -> UITapGestureRecognizer {

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toUserProfile))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }
    
    // MARK: - Segues
    
    @IBAction func toUserProfile() {
        
        guard let delegate = delegate else { return }
        
        if AuthorizationDataProvider.shared.appIsInOfflineMode {
            Alert.showOfflineModeMessage(on: delegate)
        } else {
            delegate.showSpinnerCallback()
            RequestService.shared.postId = postID
            
            let getPostRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.postsId)
            PostsDataProvider.shared.getPostInfo(request: getPostRequest, sender: delegate) { (post) in
                DispatchQueue.main.async {
                    delegate.showProfile(of: post.author)
                }
            }
        }
    }
    
    @IBAction func showUsersLikedPost(_ sender: UIButton) {
        
        guard let delegate = delegate else { return }
        
        if AuthorizationDataProvider.shared.appIsInOfflineMode {
            Alert.showOfflineModeMessage(on: delegate)
        } else {
            delegate.showSpinnerCallback()
            RequestService.shared.postId = postID
            
            let getPostRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.postsId, caseJson: nil)
            PostsDataProvider.shared.getPostInfo(request: getPostRequest, sender: delegate) { (post) in
                RequestService.shared.userId = post.author
                
                DispatchQueue.main.async {
                    delegate.showUsersLikedPost(in: self)
                }
            }
        }
    }
}
