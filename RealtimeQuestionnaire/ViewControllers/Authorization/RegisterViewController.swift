//
//  RegisterViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/18.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import FirebaseAuth
import RxSwift
import RxCocoa

class RegisterViewController: UIViewController {
    
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
    }
    
    func bind() {
        // TODO: 必要な項目を入力していない時に、アラートを表示する（カスタムクラス化しちゃっても良さそう）
        
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
                debugPrint("*** login succeeded ***")
                vc.registeringEmail.text = ""
                vc.registeringPassword.text = ""
                vc.perform(segue: StoryboardSegue.Register.showLogin)
            } else {
                debugPrint("*** user not found ***")
                // エラー処理
            }
        }
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        registeringEmail.resignFirstResponder()
        registeringPassword.resignFirstResponder()
        return true
    }
}
