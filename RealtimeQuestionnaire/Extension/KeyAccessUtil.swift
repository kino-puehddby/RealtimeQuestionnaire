//
//  KeyAccessUtil.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/26.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation
import KeychainAccess

let SERVICE_NAME = "com.hisayasugita.RealtimeQuestionnaire"

final class KeyAccessUtil {
    private init() {}
    static let shared = KeyAccessUtil()
    private let keychain = Keychain(service: SERVICE_NAME)
}

// MARK: Keychain
extension KeyAccessUtil {
    func getKeychain(_ key: KeychainKeys) -> String? {
        return keychain[key.rawValue]
    }
    
    func setKeychain(_ key: KeychainKeys, _ value: String?) {
        keychain[key.rawValue] = value
    }
}

// MARK: UserDefaults
extension KeyAccessUtil {
    func setDefaultUserDefaults() {
        UserDefaults.standard.register(defaults: [UserDefaultsKeys.isFirstLaunch.rawValue: true])
    }
    
    func setUserDefaults<T>(_ key: UserDefaultsKeys, _ value: T) {
        UserDefaults.standard[key] = value
    }
    
    func getUserDefaults<T: Any>(_ key: UserDefaultsKeys) -> T? {
        return UserDefaults.standard[key]
    }
    
    func removeUserDefaults(_ key: UserDefaultsKeys) {
        UserDefaults.standard.remove(key)
    }
}

// MARK: Access Keys
extension KeyAccessUtil {
    enum KeychainKeys: String {
        case uid
    }
    
    enum UserDefaultsKeys: String {
        // Sample
        case isFirstLaunch
    }
}
