//
//  SearchUserViewModel.swift
//  RealtimeQuestionnaire
//
//  Created by HisayaSugita on 2019/03/03.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import FirebaseFirestore

final class SearchUserViewModel {
    
    let checkedUserInfo = PublishSubject<(id: String, index: Int)>()
    let userList = BehaviorRelay<[UserModel.Fields]>(value: [])
    let checkList = BehaviorRelay<[UserModel.Fields]>(value: [])
    
    private let disposeBag = DisposeBag()
    
    init() {
        Firestore.firestore().rx
            .observeArray(
                UserModel.Fields.self,
                collectionRef: UserModel.makeCollectionRef()
            )
            .subscribe { [weak self] event in
                guard let vc = self else { return }
                switch event {
                case .next(let list):
                    vc.userList.accept(list)
                case .error(let error):
                    debugPrint(error)
                case .completed:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        checkedUserInfo
            .map { [unowned self] arg in
                // すでに同じコミュニティのアンケートリストがあったら削除、なければ追加
                let valids = self.checkList.value.map { element in
                    element.id == arg.id
                }
                if valids.contains(true) {
                    var new = self.checkList.value
                    new.remove(at: arg.index)
                    return new
                } else {
                    var new = self.checkList.value
                    new.append(self.userList.value[arg.index])
                    return new
                }
            }
            .bind(to: checkList)
            .disposed(by: disposeBag)
    }
}
