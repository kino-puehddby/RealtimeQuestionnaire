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
    
    // TODO: ローディング
    
    let checkedUserInfo = PublishSubject<(id: String, index: Int)>()
    let userList = BehaviorRelay<[UserModel.Fields]>(value: [])
    let filteredUserList = BehaviorRelay<[UserModel.Fields]>(value: [])
    let checkList = BehaviorRelay<[UserModel.Fields]>(value: [])
    
    let filterTrigger = PublishSubject<String?>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        Firestore.firestore().rx
            .getArray(
                UserModel.Fields.self,
                collectionRef: UserModel.makeCollectionRef()
            )
            .subscribe { [weak self] event in
                guard let vm = self else { return }
                switch event {
                case .success(let list):
                    vm.userList.accept(list)
                    vm.filteredUserList.accept(list)
                case .error(let error):
                    debugPrint(error)
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
                    new.append(self.filteredUserList.value[arg.index])
                    return new
                }
            }
            .bind(to: checkList)
            .disposed(by: disposeBag)
        
        filterTrigger
            .subscribe(onNext: { [unowned self] text in
                if let text = text, text != "" {
                    let filteredList = self.userList.value.filter { $0.nickname?.contains(text) ?? false }
                    self.filteredUserList.accept(filteredList)
                } else {
                    self.filteredUserList.accept(self.userList.value)
                }
            })
            .disposed(by: disposeBag)
    }
}
