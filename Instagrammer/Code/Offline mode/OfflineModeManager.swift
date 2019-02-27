import UIKit

final class OfflineModeManager {
    
    static let shared = OfflineModeManager()
    private let context = CoreDataManager.instance.context
    
    public func createPostStorage(from posts: [Post]) {
        
        CoreDataManager.instance.clearAllObjects(ofType: PostEntity.self)
        posts.forEach {savePost($0)}
        CoreDataManager.instance.save(context: context)
    }
    
    public func updatePostStorage(with posts: [Post]) {
        
        saveNotExistingPosts(posts)
        CoreDataManager.instance.save(context: context)
    }
    
    public func saveCurrentUser(from currentUser: User, withPosts posts: [Post]) {
        
        CoreDataManager.instance.clearAllObjects(ofType: UserEntity.self)
        
        let currentUserEntity = CoreDataManager.instance.createObject(from: UserEntity.self)
        
        let avatarUrl = URL(string: currentUser.avatar)!
        let avatarData = try? Data(contentsOf: avatarUrl)
        currentUserEntity.avatar = UIImage(data: avatarData!)
        
        currentUserEntity.currentUserFollowsThisUser = currentUser.currentUserFollowsThisUser
        currentUserEntity.currentUserIsFollowedByThisUser = currentUser.currentUserIsFollowedByThisUser
        currentUserEntity.followedByCount = Int16(currentUser.followedByCount)
        currentUserEntity.followsCount = Int16(currentUser.followsCount)
        currentUserEntity.fullname = currentUser.fullName
        currentUserEntity.id = currentUser.id
        currentUserEntity.username = currentUser.username
        
        saveNotExistingPosts(posts)
        
        CoreDataManager.instance.save(context: context)
    }
    
    public func getCurrentUserData() -> (currentUser: UserEntity, posts: [PostEntity])? {
        
        let user = CoreDataManager.instance.fetchData(for: UserEntity.self).first
        guard let currentUser = user, let id = currentUser.id else {
            return nil
        }
        
        let predicate = NSPredicate(format: "%K == %@", "author", "\(id)")
        let posts = CoreDataManager.instance.fetchData(for: PostEntity.self, predicate: predicate)
        
        return (currentUser: currentUser, posts: posts)
    }
    
    private func savePost(_ post: Post) {
        
        let postEntity = CoreDataManager.instance.createObject(from: PostEntity.self)
        postEntity.createdTime = post.createdTime
        postEntity.currentUserLikesThisPost = post.currentUserLikesThisPost!
        postEntity.desc = post.description
        postEntity.id = post.id
        
        let postImageUrl = URL(string: post.image)!
        let postImageData = try? Data(contentsOf: postImageUrl)
        postEntity.image = UIImage(data: postImageData!)
        
        postEntity.likedByCount = Int16(post.likedByCount)
        
        let avatarUrl = URL(string: post.authorAvatar)!
        let avatarData = try? Data(contentsOf: avatarUrl)
        postEntity.authorAvatar = UIImage(data: avatarData!)
        
        postEntity.author = post.author
        postEntity.authorUsername = post.authorUsername
    }
    
    private func saveNotExistingPosts(_ posts: [Post]) {
        for post in posts {
            if !CoreDataManager.instance.postExists(with: post.id) {
                savePost(post)
            }
        }
    }

}
