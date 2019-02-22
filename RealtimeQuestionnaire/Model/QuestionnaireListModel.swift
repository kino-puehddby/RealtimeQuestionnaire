//
//  QuestionnaireList.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/21.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

struct QuestionnaireListModelOld: Codable {
    internal private(set) var title: String
    internal private(set) var description: String?
    internal private(set) var choices: [String]
    
    init(title: String, description: String?, choices: [String]) {
        self.title = title
        self.description = description
        self.choices = choices
    }
}

struct QuestionnaireListModel: DatabaseCollection {
    static var collectionKey: CollectionKey = .questionnaireListGet
    var id: String
    typealias FieldType = Fields
    var fields: QuestionnaireListModel.Fields?
    public struct Fields: Codable {
        public let title: String
        public let description: String?
        public let choices: [String]
    }
    public init(id: String, fields: Fields?) {
        self.id = id
        self.fields = fields
    }
}
