//
//  QuestionnaireResultViewModel.swift
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

final class QuestionnaireResultViewModel {
    
    private let disposeBag = DisposeBag()
    
    private let communityList = BehaviorRelay<[CommunityModel.Fields]>(value: [])
    private let userList = BehaviorRelay<[UserModel.Fields]>(value: [])
    
    let communityIconImage = BehaviorRelay<UIImage?>(value: nil)
    let percentValues = BehaviorRelay<[Double]>(value: [])
    let communityName = BehaviorRelay<String>(value: "")
    let votesCount = BehaviorRelay<Int>(value: 0)
    lazy var choices: [String] = { preconditionFailure() }()
    
    init(questionnaireData: QuestionnaireModel.Fields) {
        choices = questionnaireData.choices
        
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
        
        communityList
            .skip(1)
            .subscribe(onNext: { [unowned self] list in
                self.matchQuestionnaires(communities: list, questionnaireId: questionnaireData.id)
            })
            .disposed(by: disposeBag)
        
        userList
            .skip(1)
            .subscribe(onNext: { [unowned self] list in
                var stashList: [String] = []
                var countList: [Double] = []
                // 全ユーザーの回答を集計
                list.forEach { user in
                    for questionnaire in user.questionnaires where questionnaire["id"] == questionnaireData.id {
                        stashList.append(questionnaire["answer"]!)
                    }
                }
                for index in questionnaireData.choices.indices {
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
        let imageRef = storageRef.child("images/" + communityId + ".jpg")
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
