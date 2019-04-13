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
    var id: String = "" // ドキュメントID
    typealias FieldType = Fields
    var fields: CommunityModel.Fields?
    public struct Fields: Codable, Equatable {
        public let id: String // ID
        public let name: String // コミュニティ名
        
        public init(id: String, name: String) {
            self.id = id
            self.name = name
        }
        static func == (lhs: CommunityModel.Fields, rhs: CommunityModel.Fields) -> Bool {
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
