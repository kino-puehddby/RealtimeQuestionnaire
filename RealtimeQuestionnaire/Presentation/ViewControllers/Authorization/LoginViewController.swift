//
//  LoginViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/18.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import FirebaseAuth
import GoogleSignIn
import RxSwift
import RxCocoa
import SVProgressHUD

final class LoginViewController: UIViewController {
    
    @IBOutlet weak private var registeringEmail: UITextField!
    @IBOutlet weak private var registeringPassword: UITextField!
    @IBOutlet weak private var loginButton: UIButton!
    @IBOutlet weak private var registerButton: UIButton!
    @IBOutlet weak private var googleSignInButton: UIButton!
    @IBOutlet weak private var sendPasswordReset: UIButton!
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        registeringEmail.resignFirstResponder()
        registeringPassword.resignFirstResponder()
    }
    
    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bindViews()
        bindViewModel()
        
        // この辺のTODOはゆくゆくはって感じ
        // TODO: メールアドレスを変更できるようにする
        // TODO: メールアドレスの認証にDynamicLinkを使う
        // TODO: 後からGoogleと連携できるようにする
    }
    
    private func setup() {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        registeringEmail.delegate = self
        registeringPassword.delegate = self
        
        registeringPassword.isSecureTextEntry = true
    }
    
    private func bindViews() {
        loginButton.rx.tap.asSignal()
            .emit(onNext: { [unowned self] in
                self.viewModel.login(email: self.registeringEmail.text, password: self.registeringPassword.text)
            })
            .disposed(by: disposeBag)
        
        googleSignInButton.rx.tap.asSignal()
            .do(onNext: {
                GIDSignIn.sharedInstance()?.signIn()
            })
            .map { true }
            .emit(to: viewModel.isLoading)
            .disposed(by: disposeBag)
        
        registerButton.rx.tap.asSignal()
            .emit(onNext: { [unowned self] in
                self.perform(segue: StoryboardSegue.Login.showRegister, sender: nil)
            })
            .disposed(by: disposeBag)
        
        sendPasswordReset.rx.tap.asSignal()
            .emit(onNext: { [unowned self] in
                self.showResetPasswordAlert()
            })
            .disposed(by: disposeBag)
        
        let emailValid = registeringEmail.rx.text
            .map { $0 != nil && $0 != "" }
        let passwordValid = registeringPassword.rx.text
            .map { $0 != nil && $0 != "" }
        let isValid = Observable
            .combineLatest(emailValid, passwordValid)
            .map { $0 && $1 }
            .share(replay: 1)
        isValid
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        isValid
            .map { $0 ? Asset.systemBlue.color : .lightGray }
            .bind(to: loginButton.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        viewModel.isLoading
            .bind(to: rx.hud)
            .disposed(by: disposeBag)
        
        viewModel.completed
            .subscribe(onNext: { [unowned self] status in
                self.viewModel.isLoading.onNext(false)
                switch status {
                case .success:
                    self.validMemberInfoAndPresent()
                case .error(let error):
                    self.showAlert(type: .ok, message: L10n.Alert.InvalidLogin.message, completion: {
                        self.registeringPassword.text = ""
                    })
                    debugPrint(error)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func showResetPasswordAlert() {
        let alert = UIAlertController(
            title: L10n.Alert.Auth.resetPassword,
            message: L10n.Alert.Auth.inputEmailAddress,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: L10n.Common.ok, style: .default) {  _ in
            guard let textfields = alert.textFields else { return }
            let email = textfields[0].text ?? ""
            // パスワードのリセット
            Auth.auth().sendPasswordReset(withEmail: email, completion: { error in
                if let error = error {
                    debugPrint(error)
                }
            })
        }
        let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alert.addTextField { textfield in
            textfield.placeholder = L10n.Alert.Auth.inputEmailAddress
            textfield.keyboardType = .emailAddress
        }
        present(alert, animated: true)
    }
    
    private func validMemberInfoAndPresent() {
        guard let user = viewModel.user.value else { return }
        if user.nickname == nil || user.nickname == "" {
            switchChangeMemberInfoController()
        } else {
            switchMainViewController()
        }
    }
}

extension LoginViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // login error (include cancel)
        if let error = error {
            showAlert(
                type: .ok,
                title: L10n.Common.error,
                message: error.localizedDescription
            )
            return
        }
        guard let authentication = user.authentication else { return }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: authentication.idToken,
            accessToken: authentication.accessToken
        )
        signInFirebase(with: credential)
    }
    
    private func signInFirebase(with credential: AuthCredential) {
        Auth.auth().signInAndRetrieveData(with: credential) { [unowned self] (user, error) in
            self.viewModel.isLoading.onNext(false)
            if let error = error {
                self.showAlert(
                    type: .ok,
                    title: L10n.Alert.Auth.failure,
                    message: error.localizedDescription.description
                )
                return
            }
            if let user = user {
                self.viewModel.set(uid: user.user.uid)
            }
            self.validMemberInfoAndPresent()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
