//
//  RegisterViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/18.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import FirebaseAuth
import FirebaseFirestore
import RxSwift
import RxCocoa

final class RegisterViewController: UIViewController {
    
    @IBOutlet weak private var registeringEmail: UITextField!
    @IBOutlet weak private var registeringPassword: UITextField!
    @IBOutlet weak private var registeringConfirmationPassword: UITextField!
    @IBOutlet weak private var registerButton: UIButton!
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        registeringEmail.resignFirstResponder()
        registeringPassword.resignFirstResponder()
    }
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
    }
    
    func setup() {
        registeringEmail.delegate = self
        registeringPassword.delegate = self
        
        registeringPassword.isSecureTextEntry = true
    }
    
    func bind() {
        let isPasswordValid = registeringConfirmationPassword.rx.text.orEmpty
            .map { [unowned self] text in
                self.registeringPassword.text == text
            }
            .share(replay: 1)
        isPasswordValid
            .bind(to: registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
        isPasswordValid
            .subscribe(onNext: { [unowned self] isValid in
                self.registerButton.backgroundColor = isValid ? Asset.systemBlue.color : .lightGray
            })
            .disposed(by: disposeBag)
        
        registerButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.register(
                    email: self.registeringEmail.text,
                    password: self.registeringPassword.text
                )
            })
            .disposed(by: disposeBag)
    }
    
    func register(email: String?, password: String?) {
        guard let email = email, let password = password else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
            guard let vc = self else { return }
            
            if user != nil && error == nil {
                debugPrint("*** create user succeeded ***")
                vc.registeringEmail.text = ""
                vc.registeringPassword.text = ""
                vc.navigationController?.popViewController(animated: true)
            } else {
                debugPrint("*** create user failed ***")
                // エラー処理
            }
        }
    }
    
    private func postUser() {
        let fields = UserModel.Fields(
            nickname: "",
            iconUrl: "",
            communities: []
        )
        guard let user = Auth.auth().currentUser else { return }
        Firestore.firestore().rx
            .setData(
                model: fields,
                collectionRef: UserModel.makeCollectionRef(),
                documentRef: UserModel.makeDocumentRef(id: user.uid)
            )
            .subscribe { result in
                switch result {
                case .success:
                    break
                case .error(let error):
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        registeringEmail.resignFirstResponder()
        registeringPassword.resignFirstResponder()
        return true
    }
}
