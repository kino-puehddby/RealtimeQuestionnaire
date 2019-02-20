//
//  Keychain.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/19.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation
import Security

public enum Keychain: String {
    case googleIdToken = "idToken"
    case googleAccessToken = "accessToken"
    
    // データの保存
    public func set(_ value: String) {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: self.rawValue as AnyObject,
            kSecValueData as String: value.data(using: .utf8) as AnyObject
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    // データの取得
    public func value() -> String? {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: self.rawValue as AnyObject,
            kSecValueData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == noErr else { return nil }
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
