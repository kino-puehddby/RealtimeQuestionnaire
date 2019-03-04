//
//  QuestionnaireList.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/21.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

struct QuestionnaireModel: DatabaseCollection {
    
    static var collectionKey: CollectionKey = .questionnaire
    var id: String = "" // ドキュメントID
    typealias FieldType = Fields
    var fields: QuestionnaireModel.Fields?
    public struct Fields: Codable, Equatable {
        public let id: String // ID
        public let authorId: String // 作成者
        public let title: String // アンケート名
        public let choices: [String] // アンケートの選択肢
        
        public init(id: String, authorId: String, title: String, choices: [String]) {
            self.id = id
            self.authorId = authorId
            self.title = title
            self.choices = choices
        }
        static func == (lhs: QuestionnaireModel.Fields, rhs: QuestionnaireModel.Fields) -> Bool {
            return lhs.id == rhs.id
        }
    }
    public init(id: String, fields: Fields?) {
        self.id = id
        self.fields = fields
    }
    public init(fields: QuestionnaireModel.Fields) {
        self.fields = fields
    }
}
