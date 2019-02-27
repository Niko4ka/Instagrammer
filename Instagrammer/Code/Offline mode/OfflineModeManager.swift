import UIKit
import CoreData

final class OfflineModeManager {
    
    static let shared = OfflineModeManager()
    private let context = CoreDataManager.instance.context
    
    public func createPostStorage(from posts: [Post]) {
        
        CoreDataManager.instance.clearAllObjects(ofType: PostEntity.self)
        CoreDataManager.instance.saveInBackgroundContext { (backgroundContext) in
            posts.forEach {self.savePost($0, inContext: backgroundContext)}
        }
    }
    
    public func updatePostStorage(with posts: [Post]) {
        
        CoreDataManager.instance.saveInBackgroundContext { (backgroundContext) in
            self.saveNotExistingPosts(posts, inContext: backgroundContext)
        }
    }
    
    public func saveCurrentUser(from currentUser: User, withPosts posts: [Post]) {
        
        CoreDataManager.instance.clearAllObjects(ofType: UserEntity.self)
        CoreDataManager.instance.saveInBackgroundContext { (backgroundContext) in
            self.createCurrentUserEntity(from: currentUser, inContext: backgroundContext)
            self.saveNotExistingPosts(posts, inContext: backgroundContext)
        }
    }
    
    private func createCurrentUserEntity(from currentUser: User, inContext context: NSManagedObjectContext) {
        let currentUserEntity = CoreDataManager.instance.createObject(from: UserEntity.self, inContext: context)
        
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
    
    private func savePost(_ post: Post, inContext context: NSManagedObjectContext) {
        
        let postEntity = CoreDataManager.instance.createObject(from: PostEntity.self, inContext: context)
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
    
    private func saveNotExistingPosts(_ posts: [Post], inContext context: NSManagedObjectContext) {
        for post in posts {
            if !CoreDataManager.instance.postExists(with: post.id) {
                savePost(post, inContext: context)
            }
        }
    }

}
