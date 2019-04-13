//
//  UserDefaults+subscript.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/27.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

extension UserDefaults {
    subscript<T: Any>(key: ServicesUtil.UserDefaultsKeys) -> T? {
        get {
            let value = object(forKey: key.rawValue)
            return value as? T
        }
        set {
            guard let newValue = newValue else {
                removeObject(forKey: key.rawValue)
                return
            }
            set(newValue, forKey: key.rawValue)
        }
    }
    
    func remove(_ key: ServicesUtil.UserDefaultsKeys) {
        removeObject(forKey: key.rawValue)
    }
}
