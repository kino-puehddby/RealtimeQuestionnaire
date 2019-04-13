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
    @IBOutlet weak private var passwordInvalidLabel: UILabel!
    @IBOutlet weak private var registerButton: UIButton!
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        registeringEmail.resignFirstResponder()
        registeringPassword.resignFirstResponder()
    }
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bindViews()
    }
    
    private func setup() {
        registeringEmail.delegate = self
        registeringPassword.delegate = self
        
        registeringPassword.isSecureTextEntry = true
        registeringConfirmationPassword.isSecureTextEntry = true
    }
    
    private func bindViews() {
        let isPasswordValid = registeringConfirmationPassword.rx.text
            .map { [unowned self] text in
                text != "" && text != nil && self.registeringPassword.text == text
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
        isPasswordValid
            .bind(to: passwordInvalidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        registerButton.rx.tap.asSignal()
            .emit(onNext: { [unowned self] in
                self.register(
                    email: self.registeringEmail.text,
                    password: self.registeringPassword.text
                )
            })
            .disposed(by: disposeBag)
    }
    
    private func register(email: String?, password: String?) {
        guard let email = email, let password = password else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
            guard let vc = self else { return }
            if let error = error {
                vc.showAlert(
                    type: .ok,
                    title: L10n.Common.error,
                    message: error.localizedDescription
                )
                return
            }
            
            if user != nil {
                vc.registeringEmail.text = ""
                vc.registeringPassword.text = ""
                vc.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func postUser() {
        guard let user = Auth.auth().currentUser else { return }
        let fields = UserModel.Fields(
            id: user.uid,
            nickname: "",
            communities: [],
            questionnaires: []
        )
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
