//
//  UserModel.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/26.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import FirebaseFirestore

struct UserModel: DatabaseCollection {
    static var collectionKey: CollectionKey = .user
    var id: String = ""
    typealias FieldType = Fields
    var fields: UserModel.Fields?
    public struct Fields: Codable, Equatable {
        public let id: String
        public let nickname: String? // ニックネーム
        public let iconUrl: String? // アイコンURL
        public let communities: [[String: String]] // 参加中のコミュニティ
        public let questionnaires: [[String: String]] // ユーザーが回答したアンケート
        
        public init(id: String, nickname: String?, iconUrl: String?, communities: [[String: String]], questionnaires: [[String: String]]) {
            self.id = id
            self.nickname = nickname
            self.iconUrl = iconUrl
            self.communities = communities
            self.questionnaires = questionnaires
        }
        static func ==(lhs: Fields, rhs: Fields) -> Bool {
            return lhs.id == rhs.id
        }
    }
    public init(id: String, fields: Fields?) {
        self.id = id
        self.fields = fields
    }
    public init(fields: UserModel.Fields) {
        self.fields = fields
    }
}
