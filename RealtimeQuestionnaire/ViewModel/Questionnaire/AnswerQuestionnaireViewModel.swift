//
//  AnswerQuestionnaireViewModel.swift
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

final class AnswerQuestionnaireViewModel {
    
    let authorName = BehaviorRelay<String>(value: "")
    let answerCompleted = PublishSubject<CompleteStatus>()
    
    private let userList = BehaviorRelay<[UserModel.Fields]>(value: [])
    private let user = BehaviorRelay<UserModel.Fields?>(value: nil)
    private var data: (communityName: String, communityIconImage: UIImage, questionnaire: QuestionnaireModel.Fields)?
    private var uid: String = ""
    
    private let disposeBag = DisposeBag()
    
    init(data: (communityName: String, communityIconImage: UIImage, questionnaire: QuestionnaireModel.Fields)) {
        
        self.data = data
        if let uid = KeyAccessUtil.shared.getKeychain(.uid) {
            self.uid = uid
        }
        
        Firestore.firestore().rx
            .getArray(
                UserModel.Fields.self,
                collectionRef: UserModel.makeCollectionRef()
            )
            .subscribe { [unowned self] event in
                switch event {
                case .success(let list):
                    self.userList.accept(list)
                    list.forEach({ user in
                        if user.id == self.uid {
                            self.user.accept(user)
                        }
                    })
                case .error(let error):
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
        
        userList
            .skip(1)
            .subscribe(onNext: { [unowned self] list in
                list.forEach { user in
                    if user.id == data.questionnaire.authorId {
                        self.authorName.accept(user.nickname ?? "")
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    func answer(index: Int) {
        guard let user = user.value,
            let data = data else { return }
        var questionnaires = user.questionnaires
        questionnaires.append([
            "answer": index.description,
            "id": data.questionnaire.id
            ])
        let model = UserModel.Fields(
            id: user.id,
            nickname: user.nickname,
            communities: user.communities,
            questionnaires: questionnaires
        )
        Firestore.firestore().rx
            .setData(
                model: model,
                collectionRef: UserModel.makeCollectionRef(),
                documentRef: UserModel.makeDocumentRef(id: uid)
            )
            .subscribe { [unowned self] event in
                switch event {
                case .success:
                    self.answerCompleted.onNext(.success)
                case .error(let error):
                    self.answerCompleted.onNext(.error(error))
                }
            }
            .disposed(by: disposeBag)
    }
}
