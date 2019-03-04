//
//  Const.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/01.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation
import UIKit

public struct Main {
    public struct TableView {
        public static let cellHeight: CGFloat = 80
    }
}

public struct CreateQuestionnaire {
    public struct TableView {
        public static let cellHeight: CGFloat = 80
    }
}

public struct CreateCommunity {
    public struct TableView {
        public static let cellHeight: CGFloat = 50
    }
}

public struct QuestionnaireDetail {
    public struct AnswerQuestionnaire {
        public struct TableView {
            public static let cellHeight: CGFloat = 60
        }
    }
}

// Sample
public struct Sample {
    public struct TableView {
        // A top inset from safe area
        public static let fullPosition: CGFloat = UIScreen.main.bounds.height * 0.1
        // A bottom inset from the safe area
        public static let tipPosition: CGFloat = 75
        public static let sideSpace: CGFloat = 10
        public static let width = UIScreen.main.bounds.width - sideSpace * 2
    }
}
