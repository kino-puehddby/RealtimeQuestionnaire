//
//  CreateCommunityViewModel.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/01.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import UIKit
import RxSwift
import RxCocoa
import FirebaseFirestore
import FirebaseStorage

final class CreateCommunityViewModel {
    
    let isLoading = PublishSubject<Bool>()
    
    let communityName = BehaviorRelay<String>(value: "")
    let user = BehaviorRelay<UserModel.Fields?>(value: nil)
    let completed = PublishSubject<CompleteStatus>()
    let isCommunityIdExist = PublishSubject<Bool>()
    
    var communityId: String = ""
    private lazy var userDocumentRef: DocumentReference = { preconditionFailure() }()
    
    private let disposeBag = DisposeBag()
    
    init() {
        guard let uid = KeyAccessUtil.shared.getKeychain(.uid) else { return }
        userDocumentRef = UserModel.makeDocumentRef(id: uid)
        Firestore.firestore().rx
            .get(
                UserModel.Fields.self,
                documentRef: userDocumentRef
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
    
    func generateCommunityId() {
        isLoading.onNext(true)
        // コミュニティIDの生成
        communityId = Database.generate(length: 20)
        Firestore.firestore().rx
            .getArray(
                CommunityModel.Fields.self,
                collectionRef: CommunityModel.makeCollectionRef()
            )
            .subscribe { [unowned self] event in
                switch event {
                case .success(let communities):
                    let valids = communities.map { community in
                        community.id == self.communityId
                    }
                    // 存在チェック
                    self.isCommunityIdExist.onNext(valids.contains(true))
                case .error(let error):
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func uploadFirebaseStorage(image: UIImage) {
        // 保存したイメージをFirebaseStorageに保存する
        let storageRef = Storage.storage().reference()
        
        if let data = image.pngData() {
            let reference = storageRef.child("images/community/" + communityId + ".jpg")
            reference.putData(data)
        }
    }
    
    private func createCommunity() {
        let model = CommunityModel.Fields(
            id: communityId,
            name: communityName.value
        )
        Firestore.firestore().rx
            .setData(
                model: model,
                collectionRef: CommunityModel.makeCollectionRef(),
                documentRef: CommunityModel.makeDocumentRef(id: communityId)
            )
            .subscribe { [unowned self] result in
                switch result {
                case .success:
                    // UserModelのcommunitiesの情報も更新しないといけない
                    self.updateUser()
                case .error(let error):
                    self.isLoading.onNext(false)
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func updateUser() {
        guard let user = user.value else { return }
        var communities = user.communities
        communities.append(["id": communityId, "name": communityName.value])
        let newModel = UserModel.Fields(
            id: user.id,
            nickname: user.nickname,
            communities: communities,
            questionnaires: user.questionnaires
        )
        Firestore.firestore().rx
            .update(
                new: newModel,
                documentRef: userDocumentRef
            )
            .subscribe { [unowned self] result in
                self.isLoading.onNext(false)
                switch result {
                case .success:
                    self.completed.onNext(.success)
                case .error(let error):
                    self.completed.onNext(.error(error))
                }
            }
            .disposed(by: disposeBag)
    }
}
