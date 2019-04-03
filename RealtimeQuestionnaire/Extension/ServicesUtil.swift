//
//  KeyChain.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/26.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation
import KeychainAccess

let SERVICE_NAME = "com.hisayasugita.RealtimeQuestionnaire"

final class ServicesUtil {
    private init() {}
    static let shared = ServicesUtil()
    private let keychain = Keychain(service: SERVICE_NAME)
    private let userDefaults = UserDefaults.standard
}

// MARK: Keychain
extension ServicesUtil {
    func getKeychain(_ key: KeychainKeys) -> String? {
        return keychain[key.rawValue]
    }
    
    func setKeychain(_ key: KeychainKeys, _ value: String?) {
        keychain[key.rawValue] = value
    }
}

enum Keychain_Keys: String {
    case uid
}

// MARK: UserDefaults
extension ServicesUtil {
    func setDefaultUserDefaults() {
        userDefaults.register(defaults: [UserDefaultsKeys.isLogin.rawValue: true])
    }
    
    func setUserDefaults<T>(_ key: UserDefaultsKeys, _ value: T) {
        userDefaults[key] = value
    }
    
    func getUserDefaults<T: Any>(_ key: UserDefaultsKeys) -> T? {
        return userDefaults[key]
    }
    
    func removeUserDefaults(_ key: UserDefaultsKeys) {
        userDefaults.remove(key)
    }
}

enum UserDefaults_Keys: String {
    // Sample
    case isFirstLaunch
}
