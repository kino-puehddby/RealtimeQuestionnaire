//
//  AnswerQuestionnaireViewModel.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/04.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import FirebaseFirestore
import FirebaseStorage

final class AnswerQuestionnaireViewModel {
    
    let communityIconImage = BehaviorRelay<UIImage?>(value: nil)
    let communityName = BehaviorRelay<String>(value: "")
    let authorName = BehaviorRelay<String>(value: "")
    let answerCompleted = PublishSubject<CompleteStatus>()
    
    private let communityList = BehaviorRelay<[CommunityModel.Fields]>(value: [])
    private let userList = BehaviorRelay<[UserModel.Fields]>(value: [])
    private let user = BehaviorRelay<UserModel.Fields?>(value: nil)
    private var data: QuestionnaireModel.Fields?
    private var uid: String = ""
    
    private let disposeBag = DisposeBag()
    
    init(questionnaireData: QuestionnaireModel.Fields) {
        data = questionnaireData
        if let uid = S.getKeychain(.uid) {
            self.uid = uid
        }
        
        // TODO: QuestionnaireModel.FieldsにCommunityIDがあったほうが嬉しい？
        
        Firestore.firestore().rx
            .getArray(
                CommunityModel.Fields.self,
                collectionRef: CommunityModel.makeCollectionRef()
            )
            .subscribe { [unowned self] event in
                switch event {
                case .success(let list):
                    self.communityList.accept(list)
                case .error(let error):
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
        
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
        
        communityList
            .skip(1)
            .subscribe(onNext: { [unowned self] list in
                self.matchQuestionnaires(communities: list, questionnaireId: questionnaireData.id)
            })
            .disposed(by: disposeBag)
        
        userList
            .skip(1)
            .subscribe(onNext: { [unowned self] list in
                list.forEach { user in
                    if user.id == questionnaireData.authorId {
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
            "id": data.id
            ])
        let model = UserModel.Fields(
            id: user.id,
            nickname: user.nickname,
            iconUrl: user.iconUrl,
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
    
    private func matchQuestionnaires(communities: [CommunityModel.Fields], questionnaireId: String) {
        communities.forEach { community in
            Firestore.firestore().rx
                .getArray(
                    QuestionnaireModel.Fields.self,
                    collectionRef: CommunityModel.makeDocumentRef(id: community.id).collection(QuestionnaireModel.collectionKey.rawValue)
                )
                .subscribe { [unowned self] event in
                    switch event {
                    case .success(let list):
                        list.forEach { element in
                            if element.id == questionnaireId {
                                self.communityName.accept(community.name)
                                self.downloadImage(communityId: community.id)
                            }
                        }
                    case .error(let error):
                        debugPrint(error)
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    private func downloadImage(communityId: String) {
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images/community/" + communityId + ".jpg")
        imageRef.getData(maxSize: 1 * 1024 * 1024) { [communityIconImage] (data, error) in
            if let error = error {
                debugPrint(error)
                return
            }
            if let data = data {
                let image = UIImage(data: data)
                communityIconImage.accept(image)
            }
        }
    }
}
