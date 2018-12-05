//
//  Post.swift
//  Course2FinalTask
//
//  Created by Вероника Данилова on 09.11.2018.
//  Copyright © 2018 e-Legion. All rights reserved.
//

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
