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
import SVProgressHUD

final class SearchCommunityViewModel {
    
    let checkedCommunityInfo = PublishSubject<(id: String, index: Int)>()
    let decideAction = PublishSubject<(isCheckedList: [Bool], isFilttered: Bool)>()
    let communityList = BehaviorRelay<[CommunityModel.Fields]>(value: [])
    let filteredCommunityList = BehaviorRelay<[CommunityModel.Fields]>(value: [])
    let checkList = BehaviorRelay<[CommunityModel.Fields]>(value: [])
    
    let filterTrigger = PublishSubject<String?>()
    
    private let disposeBag = DisposeBag()
    
    init() {
        SVProgressHUD.show()
        
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
                    vm.communityList.accept(list)
                    vm.filteredCommunityList.accept(list)
                case .error(let error):
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
        
        decideAction
            .map { arg in
                if arg.isFilttered {
                    var list: [CommunityModel.Fields] = []
                    for (index, isChecked) in arg.isCheckedList.enumerated() where isChecked {
                        list.append(self.filteredCommunityList.value[index])
                    }
                    return list
                } else {
                    var list: [CommunityModel.Fields] = []
                    for (index, isChecked) in arg.isCheckedList.enumerated() where isChecked {
                        list.append(self.communityList.value[index])
                    }
                    return list
                }
            }
            .bind(to: checkList)
            .disposed(by: disposeBag)
        
        filterTrigger
            .subscribe(onNext: { [unowned self] text in
                if let text = text, text != "" {
                    let filteredList = self.communityList.value.filter { $0.name.contains(text) }
                    self.filteredCommunityList.accept(filteredList)
                } else {
                    self.filteredCommunityList.accept(self.communityList.value)
                }
            })
            .disposed(by: disposeBag)
    }
}
