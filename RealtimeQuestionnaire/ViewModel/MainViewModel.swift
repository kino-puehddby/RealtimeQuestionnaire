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
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class MainViewModel {
    
    // TODO: ローディング
    
    let questionnaireList = BehaviorRelay<[[QuestionnaireModel.Fields]]>(value: [])
    let user = BehaviorRelay<UserModel.Fields?>(value: nil)
    let communities = BehaviorRelay<[CommunityModel.Fields]>(value: [])
    let communityNames = BehaviorRelay<[String]>(value: [])
    let communityIconImages = BehaviorRelay<[UIImage]>(value: [])
    
    var stashList: [[QuestionnaireModel.Fields]] = []
    var imageStashList: [UIImage] = []
    
    var selectedCellData = BehaviorRelay<QuestionnaireModel.Fields?>(value: nil)
    
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
                guard let vm = self else { return }
                switch event {
                case .next(let user):
                    vm.user.accept(user)
                case .error(let error):
                    debugPrint(error)
                case .completed:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        // observe Community
        Firestore.firestore().rx
            .observeArray(
                CommunityModel.Fields.self,
                collectionRef: CommunityModel.makeCollectionRef()
            )
            .subscribe { [weak self] event in
                guard let vm = self else { return }
                switch event {
                case .next(let communities):
                    vm.downloadImage(communities: communities)
                    vm.communities.accept(communities)
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
        communityIds.forEach { dic in
            // observe Questionnaire
            guard let id = dic["id"],
                id != "" else { return }
            Firestore.firestore().rx
                .observeArray(
                    QuestionnaireModel.Fields.self,
                    collectionRef: CommunityModel.makeCollectionRef().document(id).collection(CollectionKey.questionnaire.rawValue)
                )
                .subscribe { [weak self] event in
                    guard let vm = self else { return }
                    switch event {
                    case .next(let list):
                        // FIXME: ちょっと汚い
                        var target: Int = 0
                        for (index, data) in communityIds.enumerated() where data["id"] == id {
                            target = index
                        }
                        // すでに同じコミュニティのアンケートリストがあったら置き換え、なければ追加
                        if vm.stashList.indices.contains(target) {
                            vm.stashList.remove(at: target)
                            vm.stashList.insert(list, at: target)
                        } else {
                            vm.stashList.append(list)
                        }
                        vm.questionnaireList.accept(vm.stashList)
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
            guard let id = dic["id"] else { return }
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
    
    private func downloadImage(communities: [CommunityModel.Fields]) {
        imageStashList = []
        for (index, community) in communities.enumerated() {
            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child("images/" + community.id + ".jpg")
            imageRef.getData(maxSize: 1 * 1024 * 1024) { [communityIconImages] (data, _) in
                if let data = data,
                    let image = UIImage(data: data),
                    !communityIconImages.value.indices.contains(index) {
                    self.imageStashList.append(image)
                } else {
                    self.imageStashList.append(Asset.picture.image)
                }
                self.communityIconImages.accept(self.imageStashList)
            }
        }
    }
}
