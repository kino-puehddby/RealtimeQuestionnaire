//
//  ChangeMemberInfoViewModel.swift
//  RealtimeQuestionnaire
//
//  Created by HisayaSugita on 2019/03/09.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import FirebaseStorage
import FirebaseFirestore

final class ChangeMemberInfoViewModel {
    
    let iconImage = BehaviorRelay<UIImage?>(value: nil)
    let nickname = BehaviorRelay<String?>(value: nil)
    let user = BehaviorRelay<UserModel.Fields?>(value: nil)
    let belongingList = BehaviorRelay<[CommunityModel.Fields]>(value: [])
    
    let completed = PublishSubject<CompleteStatus>()
    
    private lazy var userDocumentRef: DocumentReference = { preconditionFailure() }()
    private let disposeBag = DisposeBag()
    
    init() {
        guard let uid = S.getKeychain(.uid) else { return }
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
                    self.nickname.accept(user.nickname)
                    self.downloadIconImage()
                case .error(let error):
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
        
        Firestore.firestore().rx
            .getArray(
                CommunityModel.Fields.self,
                collectionRef: CommunityModel.makeCollectionRef()
            )
            .subscribe { [weak self] event in
                guard let vm = self else { return }
                switch event {
                case .success(let list):
                    vm.addCheckList(list: list)
                case .error(let error):
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func updateMemberInfo() {
        guard let user = user.value else { return }
        let communities = belongingList.value.map { ["id": $0.id, "name": $0.name] }
        let model = UserModel.Fields(
            id: user.id,
            nickname: nickname.value,
            iconUrl: user.iconUrl,
            communities: communities,
            questionnaires: user.questionnaires
        )
        Firestore.firestore().rx
            .setData(
                model: model,
                collectionRef: UserModel.makeCollectionRef(),
                documentRef: userDocumentRef
            )
            .subscribe { [weak self] event in
                guard let vm = self else { return }
                switch event {
                case .success:
                    vm.completed.onNext(.success)
                case .error(let error):
                    vm.completed.onNext(.error(error))
                }
            }
            .disposed(by: disposeBag)
    }
    
    func uploadFirebaseStorage() {
        // 保存したイメージをFirebaseStorageに保存する
        let storageRef = Storage.storage().reference()
        if let image = iconImage.value, let data = image.pngData(),
            let user = user.value {
            let reference = storageRef.child("images/user/" + user.id + ".jpg")
            reference.putData(data)
        }
    }
    
    private func addCheckList(list: [CommunityModel.Fields]) {
        guard let user = user.value else { return }
        let communityIds = user.communities.map { $0["id"] }
        let belonging = list.filter { communityIds.contains($0.id) }
        belongingList.accept(belonging)
    }
    
    private func downloadIconImage() {
        guard let user = user.value else { return }
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images/user/" + user.id + ".jpg")
            imageRef.getData(maxSize: 1 * 1024 * 1024) { [iconImage] (data, _) in
            if let data = data {
                iconImage.accept(UIImage(data: data))
            }
        }
    }
}
