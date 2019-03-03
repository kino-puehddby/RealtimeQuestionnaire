//
//  CommunityModel.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/27.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import FirebaseFirestore

struct CommunityModel: DatabaseCollection {
    static var collectionKey: CollectionKey = .community
    var id: String = ""
    typealias FieldType = Fields
    var fields: CommunityModel.Fields?
    public struct Fields: Codable, Equatable {
        public let id: String // ID
        public let iconUrl: String // アイコンURL
        public let name: String // コミュニティ名
        
        public init(id: String, iconUrl: String, name: String) {
            self.id = id
            self.iconUrl = iconUrl
            self.name = name
        }
        static func ==(lhs: Fields, rhs: Fields) -> Bool {
            return lhs.id == rhs.id
        }
    }
    public init(id: String, fields: Fields?) {
        self.id = id
        self.fields = fields
    }
    public init(fields: CommunityModel.Fields) {
        self.fields = fields
    }
}
