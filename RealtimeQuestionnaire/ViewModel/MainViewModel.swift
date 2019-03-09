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
    
//    var stashList: [[QuestionnaireModel.Fields]] = []
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
                guard let vm = self,
                    let user = user else { return }
                vm.observeQuestionnaires(on: user.communities)
                vm.observeCommunities(on: user.communities)
            })
            .disposed(by: disposeBag)
    }
    
    func answered(id: String) -> Bool {
        guard let user = user.value else { return false }
        let usersQuestionnairesIds = user.questionnaires.map { $0["id"] }
        return usersQuestionnairesIds.contains(id)
    }
    
    private func observeQuestionnaires(on communityIds: [[String: String]]) {
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
                        var stashList = vm.questionnaireList.value
                        let ids = communityIds.map { $0["id"] }
                        guard let index = ids.firstIndex(of: id) else { return }
                        // すでに同じコミュニティのアンケートリストがあったら置き換え、なければ追加
                        if stashList.indices.contains(index) {
                            stashList.remove(at: index)
                            stashList.insert(list, at: index)
                        } else {
                            stashList.append(list)
                        }
                        vm.questionnaireList.accept(stashList)
                    case .error(let error):
                        debugPrint(error)
                    case .completed:
                        break
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    private func observeCommunities(on communityIds: [[String: String]]) {
        var newList: [String] = []
        communityIds.forEach { dic in
            guard let id = dic["id"] else { return }
            Firestore.firestore().rx
                .observeModel(
                    CommunityModel.Fields.self,
                    documentRef: CommunityModel.makeCollectionRef().document(id)
                )
                .subscribe { [weak self] event in
                    guard let vm = self else { return }
                    switch event {
                    case .next(let community):
                        newList.append(community.name)
                        vm.communityNames.accept(newList)
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
            let imageRef = storageRef.child("images/community/" + community.id + ".jpg")
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
