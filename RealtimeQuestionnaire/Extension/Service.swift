//
//  KeyChain.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/26.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation
import KeychainAccess

final class ServicesUtil {
    private init() {}
    static let shared = ServicesUtil()
    static let keychain = Keychain(service: "com.hisayasugita.RealtimeQuestionnaire")
    static let userDefaults = UserDefaults.standard
}

// MARK: Keychain
extension ServicesUtil {
    static func getKeychain(_ key: KeychainKeys) -> String? {
        return keychain[key.rawValue]
    }
    
    static func setKeychain(_ key: KeychainKeys, _ value: String?) {
        keychain[key.rawValue] = value
    }
}

// MARK: UserDefaults
extension ServicesUtil {
    static func setDefaultUserDefaults() {
        userDefaults.register(defaults: [UserDefaultsKeys.isLogin.rawValue: true])
    }
    
    static func setUserDefaults<T>(_ key: UserDefaultsKeys, _ value: T) {
        userDefaults[key] = value
    }
    
    static func getUserDefaults<T: Any>(_ key: UserDefaultsKeys) -> T? {
        return userDefaults[key]
    }
    
    static func removeUserDefaults(_ key: UserDefaultsKeys) {
        userDefaults.remove(key)
    }
}
