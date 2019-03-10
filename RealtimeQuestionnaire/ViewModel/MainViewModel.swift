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
import SVProgressHUD

final class MainViewModel {
    
    let user = BehaviorRelay<UserModel.Fields?>(value: nil)
    private let makeCommunityInfos = PublishSubject<[(id: String, name: String)]>()
    private let makeCommunitySummary = PublishSubject<[(id: String, name: String, image: UIImage)]>()
    let summary = BehaviorRelay<[(id: String, name: String, image: UIImage, questionnaires: [QuestionnaireModel.Fields])]>(value: [])
    
    let selectedCellData = BehaviorRelay<(communityName: String, communityIconImage: UIImage, questionnaire: QuestionnaireModel.Fields)?>(value: nil)
    
    private let disposeBag = DisposeBag()
    
    init() {
        SVProgressHUD.show()
        
        // observe User
        guard let uid = S.getKeychain(.uid) else { return }
        let userDocumentRef = UserModel.makeDocumentRef(id: uid)
        Firestore.firestore().rx
            .observeModel(
                UserModel.Fields.self,
                documentRef: userDocumentRef
            )
            .subscribe { [unowned self] event in
                switch event {
                case .next(let user):
                    self.user.accept(user)
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
            .subscribe(onNext: { [unowned self] user in
                guard let user = user else { return }
                let communityIds = user.communities.map { $0["id"] }
                // belonging communities
                self.observeBelongingCommunities(on: communityIds)
            })
            .disposed(by: disposeBag)
        
        makeCommunityInfos
            .subscribe(onNext: { [unowned self] arg in
                self.downloadImage(communityNameWithIds: arg)
            })
            .disposed(by: disposeBag)
        
        makeCommunitySummary
            .subscribe(onNext: { [unowned self] arg in
                self.observeQuestionnaires(on: arg)
            })
            .disposed(by: disposeBag)
    }
    
    func answered(id: String) -> Bool {
        guard let user = user.value else { return false }
        let usersQuestionnairesIds = user.questionnaires.map { $0["id"] }
        return usersQuestionnairesIds.contains(id)
    }
    
    private func observeBelongingCommunities(on communityIds: [String?]) {
        var newList: [(id: String, name: String)] = []
        communityIds.forEach { id in
            guard let id = id else { return }
            Firestore.firestore().rx
                .observeModel(
                    CommunityModel.Fields.self,
                    documentRef: CommunityModel.makeCollectionRef().document(id)
                )
                .subscribe { [unowned self] event in
                    switch event {
                    case .next(let community):
                        newList.append((id: community.id, name: community.name))
                        if newList.count == communityIds.count {
                            self.makeCommunityInfos.onNext(newList)
                        }
                    case .error(let error):
                        debugPrint(error)
                    case .completed:
                        break
                    }
                }
                .disposed(by: disposeBag)
        }
    }
    
    private func downloadImage(communityNameWithIds: [(id: String, name: String)]) {
        var communityInfoStashList: [(id: String, name: String, image: UIImage)] = []
        communityNameWithIds.forEach { community in
            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child("images/community/" + community.id + ".jpg")
            imageRef.getData(maxSize: 1 * 1024 * 1024) { [unowned self] (data, error) in
                if let error = error {
                    debugPrint(error)
                    communityInfoStashList.append((id: community.id, name: community.name, image: Asset.picture.image))
                }
                if let data = data,
                    let image = UIImage(data: data) {
                    communityInfoStashList.append((id: community.id, name: community.name, image: image))
                }
                if communityInfoStashList.count == communityNameWithIds.count {
                    self.makeCommunitySummary.onNext(communityInfoStashList)
                }
            }
        }
    }
    
    private func observeQuestionnaires(on infos: [(id: String, name: String, image: UIImage)]) {
        var stashList: [(id: String, name: String, image: UIImage, questionnaires: [QuestionnaireModel.Fields])] = []
        infos.forEach { info in
            // observe Questionnaire
            Firestore.firestore().rx
                .observeArray(
                    QuestionnaireModel.Fields.self,
                    collectionRef: CommunityModel.makeCollectionRef().document(info.id).collection(CollectionKey.questionnaire.rawValue)
                )
                .subscribe { [unowned self] event in
                    
                    switch event {
                    case .next(let questionnaireList):
                        stashList.append((
                            id: info.id,
                            name: info.name,
                            image: info.image,
                            questionnaires: questionnaireList
                        ))
                        if stashList.count == infos.count {
                            self.summary.accept(stashList)
                            stashList = []
                        }
                        SVProgressHUD.dismiss()
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
