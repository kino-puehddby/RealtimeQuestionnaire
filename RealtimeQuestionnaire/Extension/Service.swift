//
//  KeyChain.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/26.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation
import KeychainAccess

let S: Service.Type = Service.self

let SERVICE_NAME = "com.hisayasugita.RealtimeQuestionnaire"

struct Service {
    private init() {}
    static let keychain = Keychain(service: SERVICE_NAME)
    static let userDefaults = UserDefaults.standard
}

// MARK: Keychain
enum Keychain_Keys: String {
    case uid
}

extension Service {
    static func getKeychain(_ key: Keychain_Keys) -> String? {
        return keychain[key.rawValue]
    }
    
    static func setKeychain(_ key: Keychain_Keys, _ value: String?) {
        keychain[key.rawValue] = value
    }
}

// MARK: UserDefaults
enum UserDefaults_Keys: String {
    // Sample
    case isFirstLaunch
}

extension Service {
    static func setDefaultUserDefaults() {
        userDefaults.register(defaults: [UserDefaults_Keys.isFirstLaunch.rawValue: true])
    }
    
    static func setUserDefaults<T>(_ key: UserDefaults_Keys, _ value: T) {
        userDefaults[key] = value
    }
    
    static func getUserDefaults<T: Any>(_ key: UserDefaults_Keys) -> T? {
        return userDefaults[key]
    }
    
    static func removeUserDefaults(_ key: UserDefaults_Keys) {
        userDefaults.remove(key)
    }
}
