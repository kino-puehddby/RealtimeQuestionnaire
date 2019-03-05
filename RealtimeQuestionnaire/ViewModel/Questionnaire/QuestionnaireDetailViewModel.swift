//
//  QuestionnaireDetailViewModel.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/04.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import FirebaseFirestore

final class QuestionnaireDetailViewModel {
    
    private let disposeBag = DisposeBag()
    
    let mode = BehaviorRelay<QuestionnaireDetailMode>(value: .answer)
    
    enum QuestionnaireDetailMode {
        case answer
        case result
    }
    
    init(questionnaireData: QuestionnaireModel.Fields, user: UserModel.Fields) {
        let answered = user.questionnaires
            .map { answeredQuestionnaire in
                answeredQuestionnaire["id"] == questionnaireData.id
            }
            .filter { $0 == true }
        if answered.isEmpty {
            // 未回答
            mode.accept(.answer)
        } else {
            // 回答済み
            mode.accept(.result)
        }
    }
}