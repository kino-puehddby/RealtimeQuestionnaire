//
//  MainViewModel.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/28.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import RxCocoa
import RxSwift
import FirebaseFirestore

final class MainViewModel {
    
    let questionnaireList = BehaviorRelay<[[QuestionnaireModel.Fields]]>(value: [])
    let user = BehaviorRelay<UserModel.Fields?>(value: nil)
    var communityNames = BehaviorRelay<[String]?>(value: nil)
    
    private let disposeBag = DisposeBag()
    
    init() {
        // observe User
        guard let uid = S.getKeychain(.uid) else { return }
        let userDocumentRef = UserModel.makeDocumentRef(id: uid)
        Firestore.firestore().rx
            .observeModel(
                UserModel.Fields.self,
                documentRef: userDocumentRef
            )
            .subscribe { [weak self] event in
                guard let vc = self else { return }
                switch event {
                case .next(let user):
                    vc.user.accept(user)
                case .error(let error):
                    debugPrint(error)
                case .completed:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        // observe Questionnaires associated with User
        user
            .skip(1)
            .subscribe(onNext: { [weak self] user in
                guard let vc = self,
                    let user = user else { return }
                vc.observeQuestionnaires(on: user.communities)
                vc.observeCommunities(on: user.communities)
            })
            .disposed(by: disposeBag)
    }
    
    func observeQuestionnaires(on communityIds: [[String: String]]) {
        questionnaireList.accept([])
        var newList: [[QuestionnaireModel.Fields]] = []
        communityIds.forEach { dic in
            // observe Questionnaire
            guard let id = dic[UsersCommunity.id.rawValue] else { return }
            Firestore.firestore().rx
                .observeArray(
                    QuestionnaireModel.Fields.self,
                    collectionRef: CommunityModel.makeCollectionRef().document(id).collection(CollectionKey.questionnaire.rawValue)
                )
                .subscribe { [weak self] event in
                    guard let vc = self else { return }
                    switch event {
                    case .next(let list):
                        newList.append(list)
                        vc.questionnaireList.accept(newList)
                    case .error(let error):
                        debugPrint(error)
                    case .completed:
                        break
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    func observeCommunities(on communityIds: [[String: String]]) {
        var newList: [String] = []
        communityIds.forEach { dic in
            guard let id = dic[UsersCommunity.id.rawValue] else { return }
            Firestore.firestore().rx
                .observeModel(
                    CommunityModel.Fields.self,
                    documentRef: CommunityModel.makeCollectionRef().document(id)
                )
                .subscribe { [weak self] event in
                    guard let vc = self else { return }
                    switch event {
                    case .next(let community):
                        newList.append(community.name)
                        vc.communityNames.accept(newList)
                    case .error(let error):
                        debugPrint(error)
                    case .completed:
                        break
                    }
                }
                .disposed(by: disposeBag)
        }
    }
}
