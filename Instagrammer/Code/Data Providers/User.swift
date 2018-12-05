//
//  User.swift
//  Course2FinalTask
//
//  Created by Вероника Данилова on 09.11.2018.
//  Copyright © 2018 e-Legion. All rights reserved.
//

import Foundation

struct User: Codable {
    var id: String
    var username: String
    var fullName: String
    var avatar: String
    var currentUserFollowsThisUser: Bool
    var currentUserIsFollowedByThisUser: Bool
    var followsCount: Int
    var followedByCount: Int
}
