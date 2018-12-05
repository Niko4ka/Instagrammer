//
//  KeychainService.swift
//  Instagrammer
//
//  Created by Вероника Данилова on 29/11/2018.
//  Copyright © 2018 e-Legion. All rights reserved.
//

import UIKit

final class KeychainService {
    
    static let shared = KeychainService()
    public let service = "Instagrammer"
    
    private func keychainQuery() -> [String : AnyObject] {
        
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        query[kSecAttrService as String] = service as AnyObject
        
        return query
    }
    
    public func readToken() -> String? {
        var query = keychainQuery()
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer(&queryResult))
        
        if status != noErr {
            return nil
        }
        
        guard let item = queryResult as? [String : AnyObject],
            let tokenData = item[kSecValueData as String] as? Data,
            let token = String(data: tokenData, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    public func saveToken(token: String) -> Bool {
        
        let tokenData = token.data(using: .utf8)
        
        if readToken() != nil {
            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = tokenData as AnyObject
            
            let query = keychainQuery()
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            return status == noErr
        }
        
        var item = keychainQuery()
        item[kSecValueData as String] = tokenData as AnyObject
        let status = SecItemAdd(item as CFDictionary, nil)
        return status == noErr
    }
    
    
    public func deleteToken() {
        let item = keychainQuery()
        _ = SecItemDelete(item as CFDictionary)
    }
    
}
