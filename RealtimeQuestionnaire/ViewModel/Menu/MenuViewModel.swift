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

final class MenuViewModel {
    
    let user = BehaviorRelay<UserModel.Fields?>(value: nil)
    
    private let disposeBag = DisposeBag()
    
    init() {
        guard let uid = S.getKeychain(.uid) else { return }
        let documentRef = UserModel.makeDocumentRef(id: uid)
        Firestore.firestore().rx
            .get(
                UserModel.Fields.self,
                documentRef: documentRef
            )
            .subscribe { [unowned self] result in
                switch result {
                case .success(let user):
                    self.user.accept(user)
                case .error(let error):
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
    }
}
