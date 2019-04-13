//
//  LoginViewModel.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/04.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import FirebaseAuth
import FirebaseFirestore
import SVProgressHUD

final class LoginViewModel {
    
    private let disposeBag = DisposeBag()
    
    let isLoading = PublishSubject<Bool>()
    let completed = PublishSubject<CompleteStatus>()
    let user = BehaviorRelay<UserModel.Fields?>(value: nil)
    let getUserAction = PublishSubject<Void>()
    
    init() {}
    
    func login(email: String?, password: String?) {
        SVProgressHUD.show()
        guard let email = email, let password = password else { return }
        isLoading.onNext(true)
        
        Auth.auth().signIn(withEmail: email, password: password) { [unowned self] (user, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.completed.onNext(.error(error))
                return
            }
            guard let user = user else { return }
            self.set(uid: user.user.uid)
            self.completed.onNext(.success)
        }
        
        getUserAction
            .subscribe(onNext: { [unowned self] in
                self.getUser()
            })
            .disposed(by: disposeBag)
    }
    
    func set(uid: String) {
        if ServicesUtil.shared.getKeychain(.uid) == nil {
            ServicesUtil.shared.setKeychain(.uid, uid)
        }
        getUserAction.onNext(())
    }
    
    func getUser() {
        // observe User
        guard let uid = ServicesUtil.shared.getKeychain(.uid) else { return }
        let userDocumentRef = UserModel.makeDocumentRef(id: uid)
        Firestore.firestore().rx
            .get(
                UserModel.Fields.self,
                documentRef: userDocumentRef
            )
            .subscribe { [unowned self] event in
                switch event {
                case .success(let user):
                    self.user.accept(user)
                case .error(let error):
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
    }
}
