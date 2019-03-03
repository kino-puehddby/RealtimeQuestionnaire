//
//  CreateCommunityViewModel.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/01.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import FirebaseFirestore

final class CreateCommunityViewModel {
    
    let communityName = BehaviorRelay<String>(value: "")
    let user = BehaviorRelay<UserModel.Fields?>(value: nil)
    let postCompleted = PublishSubject<CompleteStatus>()
    let userUpdated = PublishSubject<CompleteStatus>()
    let isCommunityIdExist = PublishSubject<Bool>()
    
    var communityDocumentId: String = ""
    var userDocumentRef: DocumentReference?
    
    private let disposeBag = DisposeBag()
    
    init() {
        guard let uid = S.getKeychain(.uid) else { return }
        userDocumentRef = UserModel.makeDocumentRef(id: uid)
        Firestore.firestore().rx
            .get(
                UserModel.Fields.self,
                documentRef: userDocumentRef!
            )
            .subscribe { [unowned self] result in
                switch result {
                case .success(let user):
                    self.user.accept(user)
                case .error(let error):
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
        
        isCommunityIdExist
            .subscribe(onNext: { [unowned self] isExist in
                isExist ? self.generateCommunityId() : self.createCommunity()
            })
            .disposed(by: disposeBag)
    }
    
    func createCommunity() {
        let model = CommunityModel.Fields(
            id: communityDocumentId,
            iconUrl: "アイコンURL", // TODO: アイコンURLを設定
            name: communityName.value
        )
        Firestore.firestore().rx
            .setData(
                model: model,
                collectionRef: CommunityModel.makeCollectionRef(),
                documentRef: CommunityModel.makeDocumentRef(id: communityDocumentId)
            )
            .subscribe { [unowned self] result in
                switch result {
                case .success:
                    self.postCompleted.onNext(.success)
                    // TODO: UserModelのcommunitiesにも情報を登録しないといけない
                    self.updateUser()
                case .error(let error):
                    self.postCompleted.onNext(.error(error))
                }
            }
            .disposed(by: disposeBag)
    }
    
    func generateCommunityId() {
        // コミュニティIDの生成
        communityDocumentId = Database.generate(length: 20)
        Firestore.firestore().rx
            .getArray(
                CommunityModel.Fields.self,
                collectionRef: CommunityModel.makeCollectionRef()
            )
            .subscribe { [unowned self] event in
                switch event {
                case .success(let communities):
                    let valids = communities.map { community in
                        community.id == self.communityDocumentId
                    }
                    // 存在チェック
                    self.isCommunityIdExist.onNext(valids.contains(true))
                case .error(let error):
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func updateUser() {
        guard let user = user.value else { return }
        var communities = user.communities
        communities.append(["id": communityDocumentId, "name": communityName.value])
        let newModel = UserModel.Fields(
            id: user.id,
            nickname: user.nickname,
            iconUrl: user.iconUrl,
            communities: communities,
            questionnaires: user.questionnaires
        )
        Firestore.firestore().rx
            .update(
                new: newModel,
                documentRef: userDocumentRef!
            )
            .subscribe { [unowned self] result in
                switch result {
                case .success:
                    self.userUpdated.onNext(.success)
                case .error(let error):
                    self.userUpdated.onNext(.error(error))
                }
            }
            .disposed(by: disposeBag)
    }
}
