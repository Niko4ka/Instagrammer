//
//  APIRequestCases.swift
//  Course2FinalTask
//
//  Created by Вероника Данилова on 10.11.2018.
//  Copyright © 2018 e-Legion. All rights reserved.
//

import Foundation

public enum APIRequestCases {
    case signin
    //        Авторизует пользователя и выдает токен.
    
    case signout
    //        Деавторизует пользователя и инвалидирует токен.
    
    case checkToken
    //        Проверяет валидность токена.
    
    case usersMe
    //        Возвращает информацию о текущем пользователе.
    
    case usersId
    //        Возвращает информацию о пользователе с запрошенным ID.
    
    case usersFollow
    //        Подписывает текущего пользователя на пользователя с запрошенным ID.
    
    case usersUnfollow
    //        Отписывает текущего пользователя от пользователя с запрошенным ID.
    
    case usersIdFollowers
    //        Возвращает подписчиков пользователя с запрошенным ID.
    
    case usersIdFollowing
    //        Возвращает подписки пользователя с запрошенным ID.
    
    case usersIdPosts
    //        Возвращает публикации пользователя с запрошенным ID.
    
    case postsFeed
    //        Возвращает публикации пользователей на которых подписан текущий пользователь.
    
    case postsId
    //        Возвращает публикацию с запрошенным ID.
    
    case postsLike
    //        Ставит лайк от текущего пользователя на публикации с запрошенным ID.
    
    case postsUnlike
    //        Удаляет лайк от текущего пользователя на публикации с запрошенным ID.
    
    case postsIdLikes
    //        Возвращает пользователей, поставивших лайк на публикацию с запрошенным ID.
    
    case postsCreate
    //        Создает новую публикацию.
    
}
