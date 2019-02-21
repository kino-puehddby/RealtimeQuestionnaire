//
//  QuestionnaireList.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/21.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

struct QuestionnaireListModel: Codable {
    internal private(set) var title: String
    internal private(set) var description: String?
    internal private(set) var choices: [String]
    
    init(title: String, description: String?, choices: [String]) {
        self.title = title
        self.description = description
        self.choices = choices
    }
}
