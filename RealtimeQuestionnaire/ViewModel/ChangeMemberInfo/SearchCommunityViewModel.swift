//
//  SearchCommunityViewModel.swift
//  RealtimeQuestionnaire
//
//  Created by HisayaSugita on 2019/03/09.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import FirebaseFirestore
import FirebaseStorage
import SVProgressHUD

final class SearchCommunityViewModel {
    
    let decideAction = PublishSubject<(isCheckedList: [Bool], isFilttered: Bool)>()
    let communityInfos = BehaviorRelay<[(id: String, name: String, image: UIImage)]>(value: [])
    let filteredCommunityInfos = BehaviorRelay<[(id: String, name: String, image: UIImage)]>(value: [])
    let belongingCommunityInfos = BehaviorRelay<[(id: String, name: String, image: UIImage)]>(value: [])
    let filterTrigger = PublishSubject<String?>()
    
    private let communityList = BehaviorRelay<[CommunityModel.Fields]>(value: [])
    private let disposeBag = DisposeBag()
    
    init(infos: [(id: String, name: String, image: UIImage)]) {
        SVProgressHUD.show()
        belongingCommunityInfos.accept(infos)
        
        Firestore.firestore().rx
            .getArray(
                CommunityModel.Fields.self,
                collectionRef: CommunityModel.makeCollectionRef()
            )
            .subscribe { [weak self] event in
                SVProgressHUD.dismiss()
                guard let vm = self else { return }
                switch event {
                case .success(let list):
                    SVProgressHUD.show()
                    vm.communityList.accept(list)
                case .error(let error):
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
        
        decideAction
            .map { arg in
                if arg.isFilttered {
                    var list: [(id: String, name: String, image: UIImage)] = []
                    for (index, isChecked) in arg.isCheckedList.enumerated() where isChecked {
                        list.append(self.filteredCommunityInfos.value[index])
                    }
                    return list
                } else {
                    var list: [(id: String, name: String, image: UIImage)] = []
                    for (index, isChecked) in arg.isCheckedList.enumerated() where isChecked {
                        list.append(self.communityInfos.value[index])
                    }
                    return list
                }
            }
            .bind(to: belongingCommunityInfos)
            .disposed(by: disposeBag)
        
        filterTrigger
            .subscribe(onNext: { [unowned self] text in
                if let text = text, text != "" {
                    let filteredInfos = self.communityInfos.value.filter { $0.name.contains(text) }
                    self.filteredCommunityInfos.accept(filteredInfos)
                } else {
                    self.filteredCommunityInfos.accept(self.communityInfos.value)
                }
            })
            .disposed(by: disposeBag)
        
        communityList
            .subscribe(onNext: { [unowned self] communities in
                self.downloadIconImage(communities: communities)
            })
            .disposed(by: disposeBag)
    }
    
    private func downloadIconImage(communities: [CommunityModel.Fields]) {
        var stashList: [(id: String, name: String, image: UIImage)] = []
        communities.forEach { community in
            let storageRef = Storage.storage().reference()
            let imageRef = storageRef.child("images/community/" + community.id + ".jpg")
            imageRef.getData(maxSize: 10 * 1024 * 1024) { [unowned self] (data, error) in
                if let error = error {
                    debugPrint(error)
                    stashList.append((
                        id: community.id,
                        name: community.name,
                        image: Asset.picture.image
                    ))
                }
                if let data = data, let image = UIImage(data: data) {
                    stashList.append((
                        id: community.id,
                        name: community.name,
                        image: image
                    ))
                }
                if self.communityList.value.count == stashList.count {
                    SVProgressHUD.dismiss()
                    self.communityInfos.accept(stashList)
                    self.filteredCommunityInfos.accept(stashList)
                }
            }
        }
    }
}
