//
//  QuestionnaireResultViewModel.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/04.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import UIKit
import RxSwift
import RxCocoa
import FirebaseFirestore
import FirebaseStorage

final class QuestionnaireResultViewModel {
    
    private let disposeBag = DisposeBag()
    
    private let userList = BehaviorRelay<[UserModel.Fields]>(value: [])
    
    let percentValues = BehaviorRelay<[Double]>(value: [])
    let votesCount = BehaviorRelay<Int>(value: 0)
    lazy var choices: [String] = { preconditionFailure() }()
    
    init(data: (communityName: String, communityIconImage: UIImage, questionnaire: QuestionnaireModel.Fields)) {
        choices = data.questionnaire.choices
        
        Firestore.firestore().rx
            .observeArray(
                UserModel.Fields.self,
                collectionRef: UserModel.makeCollectionRef()
            )
            .subscribe { [unowned self] event in
                switch event {
                case .next(let list):
                    self.userList.accept(list)
                case .error(let error):
                    debugPrint(error)
                case .completed:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        userList
            .skip(1)
            .subscribe(onNext: { [unowned self] list in
                var stashList: [String] = []
                var countList: [Double] = []
                // 全ユーザーの回答を集計
                list.forEach { user in
                    for questionnaire in user.questionnaires where questionnaire["id"] == data.questionnaire.id {
                        stashList.append(questionnaire["answer"]!)
                    }
                }
                for index in data.questionnaire.choices.indices {
                    let count = stashList.filter { $0 == index.description }.count
                    countList.append(Double(count))
                }
                let sum = countList.reduce(0) { $0 + $1 }
                self.votesCount.accept(Int(sum))
                let percentList: [Double] = countList
                    .map { Double($0) }
                    .map { $0 / sum * 100.0 }
                self.percentValues.accept(percentList)
            })
            .disposed(by: disposeBag)
    }
}
