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
    var id: String = ""
    typealias FieldType = Fields
    var fields: QuestionnaireModel.Fields?
    public struct Fields: Codable {
        public let authorId: String // 作成者
        public let title: String // アンケート名
        public let description: String? // アンケートの説明
        public let choices: [String] // アンケートの選択肢
        
        public init(authorId: String, title: String, description: String?, choices: [String]) {
            self.authorId = authorId
            self.title = title
            self.description = description
            self.choices = choices
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
