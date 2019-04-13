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

// MARK: UserDefaults
extension ServicesUtil {
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

extension ServicesUtil {
    // MARK: Access Keys
    enum KeychainKeys: String {
        case uid
    }
    
    enum UserDefaultsKeys: String {
        // Sample
        case isFirstLaunch
    }
}
