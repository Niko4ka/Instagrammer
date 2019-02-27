import Foundation

struct Post: Codable {
    var id: String
    var author: String
    var description: String
    var image: String
    var createdTime: String
    var currentUserLikesThisPost: Bool?
    var likedByCount: Int
    var authorUsername: String
    var authorAvatar: String
}
