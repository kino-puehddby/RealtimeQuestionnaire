//
//  MenuViewModel.swift
//  RealtimeQuestionnaire
//
//  Created by HisayaSugita on 2019/03/02.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import RxSwift
import RxCocoa
import FirebaseFirestore
import FirebaseStorage
import SVProgressHUD

final class MenuViewModel {
    
    let user = BehaviorRelay<UserModel.Fields?>(value: nil)
    let iconImage = BehaviorRelay<UIImage?>(value: nil)
    
    private let makeCommunityInfos = PublishSubject<[(id: String, name: String)]>()
    let belongingCommunityInfos = BehaviorRelay<[(id: String, name: String, image: UIImage)]>(value: [])
    
    private let disposeBag = DisposeBag()
    
    init() {
        SVProgressHUD.show()
        guard let uid = S.getKeychain(.uid) else { return }
        let documentRef = UserModel.makeDocumentRef(id: uid)
        Firestore.firestore().rx
            .get(
                UserModel.Fields.self,
                documentRef: documentRef
            )
            .subscribe { [unowned self] result in
                SVProgressHUD.dismiss()
                switch result {
                case .success(let user):
                    self.user.accept(user)
                    let communityIds = user.communities.map { $0["id"] }
                    self.downloadIconImage()
                    self.observeBelongingCommunities(on: communityIds)
                case .error(let error):
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
        
        makeCommunityInfos
            .subscribe(onNext: { [unowned self] communities in
                self.downloadImage(communityNameWithIds: communities)
            })
            .disposed(by: disposeBag)
    }
    
    func downloadIconImage() {
        guard let user = user.value else { return }
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images/user/" + user.id + ".jpg")
        imageRef.getData(maxSize: 10 * 1024 * 1024) { [iconImage] (data, error) in
            if let error = error {
                debugPrint(error)
                iconImage.accept(Asset.picture.image)
                return
            }
            if let data = data {
                iconImage.accept(UIImage(data: data))
            }
        }
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
            imageRef.getData(maxSize: 10 * 1024 * 1024) { [unowned self] (data, error) in
                if let error = error {
                    debugPrint(error)
                    communityInfoStashList.append((id: community.id, name: community.name, image: Asset.picture.image))
                }
                if let data = data,
                    let image = UIImage(data: data) {
                    communityInfoStashList.append((id: community.id, name: community.name, image: image))
                }
                if communityInfoStashList.count == communityNameWithIds.count {
                    self.belongingCommunityInfos.accept(communityInfoStashList)
                }
            }
        }
    }
}
