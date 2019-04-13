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
import SVProgressHUD

final class ChangeMemberInfoViewModel {
    
    let iconImage = BehaviorRelay<UIImage?>(value: nil)
    let nickname = BehaviorRelay<String?>(value: nil)
    let user = BehaviorRelay<UserModel.Fields?>(value: nil)
    
    let belongingCommunityInfos = BehaviorRelay<[(id: String, name: String, image: UIImage)]>(value: [])
    
    let completed = PublishSubject<CompleteStatus>()
    
    private lazy var userDocumentRef: DocumentReference = { preconditionFailure() }()
    private let disposeBag = DisposeBag()
    
    init(belongingCommunityInfos: [(id: String, name: String, image: UIImage)]) {
        SVProgressHUD.show()
        
        guard let uid = ServicesUtil.shared.getKeychain(.uid) else { return }
        userDocumentRef = UserModel.makeDocumentRef(id: uid)
        self.belongingCommunityInfos.accept(belongingCommunityInfos)
        
        Firestore.firestore().rx
            .get(
                UserModel.Fields.self,
                documentRef: userDocumentRef
            )
            .subscribe { [unowned self] result in
                SVProgressHUD.dismiss()
                switch result {
                case .success(let user):
                    SVProgressHUD.show()
                    self.user.accept(user)
                    self.nickname.accept(user.nickname)
                    self.downloadIconImage()
                case .error(let error):
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func updateMemberInfo() {
        guard let user = user.value else { return }
        let communities = belongingCommunityInfos.value.map { ["id": $0.id, "name": $0.name] }
        let model = UserModel.Fields(
            id: user.id,
            nickname: nickname.value,
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
                    vm.uploadFirebaseStorage()
                case .error(let error):
                    vm.completed.onNext(.error(error))
                }
            }
            .disposed(by: disposeBag)
    }
    
    func uploadFirebaseStorage() {
        // 保存したイメージをFirebaseStorageに保存する
        let storageRef = Storage.storage().reference()
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        if let image = appdelegate.photoLibraryImage, let data = image.jpegData(compressionQuality: 1),
            let user = user.value {
            let reference = storageRef.child("images/user/" + user.id + ".jpg")
            reference.putData(data, metadata: nil) { (_, error) in
                if let error = error {
                    debugPrint(error)
                }
            }
        }
    }
    
    private func downloadIconImage() {
        guard let user = user.value else { return }
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("images/user/" + user.id + ".jpg")
        imageRef.getData(maxSize: 10 * 1024 * 1024) { [iconImage] (data, error) in
            SVProgressHUD.dismiss()
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
}
