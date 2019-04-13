//
//  CreateQuestionnaireViewModel.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/28.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import FirebaseFirestore

final class CreateQuestionnaireViewModel {
    
    let isLoading = PublishSubject<Bool>()
    
    let choicesList = BehaviorRelay<[String]>(value: [])
    let communities = BehaviorRelay<[[String: String]]>(value: [])
    let viewTap = PublishSubject<Void>()
    let cellTextFieldValid = BehaviorRelay<Bool>(value: false)
    
    let selectedCommunityId = BehaviorRelay<String>(value: "")
    
    let postCompleted = PublishSubject<CompleteStatus>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        guard let uid = KeyAccessUtil.shared.getKeychain(.uid) else { return }
        let documentRef = UserModel.makeDocumentRef(id: uid)
        Firestore.firestore().rx
            .get(
                UserModel.Fields.self,
                documentRef: documentRef
            )
            .subscribe { [unowned self] result in
                switch result {
                case .success(let user):
                    self.communities.accept(user.communities)
                case .error(let error):
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func postQuestionnaire(fields: QuestionnaireModel.Fields) {
        isLoading.onNext(true)
        if selectedCommunityId.value == "" {
            return
        }
        let collectionRef = CommunityModel
            .makeDocumentRef(id: selectedCommunityId.value)
            .collection(CollectionKey.questionnaire.rawValue)
        Firestore.firestore().rx
            .setData(
                model: fields,
                collectionRef: collectionRef
            )
            .subscribe { [unowned self] result in
                self.isLoading.onNext(false)
                switch result {
                case .success:
                    self.postCompleted.onNext(.success)
                case .error(let error):
                    self.postCompleted.onNext(.error(error))
                }
            }
            .disposed(by: disposeBag)
    }
}
