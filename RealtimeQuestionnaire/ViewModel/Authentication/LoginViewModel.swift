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

final class LoginViewModel {
    
    private let disposeBag = DisposeBag()
    
    let isLoading = PublishSubject<Bool>()
    let completed = PublishSubject<CompleteStatus>()
    
    init() {}
    
    func login(email: String?, password: String?) {
        guard let email = email, let password = password else { return }
        isLoading.onNext(true)
        
        Auth.auth().signIn(withEmail: email, password: password) { [unowned self] (user, error) in
            if let error = error {
                self.completed.onNext(.error(error))
                return
            }
            guard let user = user else { return }
            self.set(uid: user.user.uid)
            self.completed.onNext(.success)
        }
    }
    
    func set(uid: String) {
        if S.getKeychain(.uid) == nil {
            S.setKeychain(.uid, uid)
        }
    }
}
