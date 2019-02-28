//
//  UserModel.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/26.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import FirebaseFirestore

enum UsersCommunity: String {
    case id
    case name
}

enum UsersQuestionnaire: String {
    case answer
    case id
}

struct UserModel: DatabaseCollection {
    static var collectionKey: CollectionKey = .user
    var id: String = ""
    typealias FieldType = Fields
    var fields: UserModel.Fields?
    public struct Fields: Codable {
        public let nickname: String? // ニックネーム
        public let iconUrl: String? // アイコンURL
        public let communities: [[String: String]] // 参加中のコミュニティ
        public let questionnaires: [[String: String]] // ユーザーが回答したアンケート
        
        public init(nickname: String?, iconUrl: String?, communities: [[String: String]], questionnaires: [[String: String]]) {
            self.nickname = nickname
            self.iconUrl = iconUrl
            self.communities = communities
            self.questionnaires = questionnaires
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
