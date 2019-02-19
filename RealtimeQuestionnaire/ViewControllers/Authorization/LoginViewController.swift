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

class LoginViewController: UIViewController {
    
    @IBOutlet weak private var registeringEmail: UITextField!
    @IBOutlet weak private var registeringPassword: UITextField!
    @IBOutlet weak private var loginButton: UIButton!
    @IBOutlet weak private var registerButton: UIButton!
    @IBOutlet weak private var googleSignInButton: UIButton!
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        registeringEmail.resignFirstResponder()
        registeringPassword.resignFirstResponder()
    }
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
        
        // TODO: パスワードを変更したい
        // TODO: 後からGoogleと連携したい
    }
    
    func setup() {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        registeringEmail.delegate = self
        registeringPassword.delegate = self
        
        registeringPassword.isSecureTextEntry = true
    }
    
    func bind() {
        loginButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.login(email: self.registeringEmail.text, password: self.registeringPassword.text)
            })
            .disposed(by: disposeBag)
        
        googleSignInButton.rx.tap
            .subscribe(onNext: {
                // 可能な場合はサイレントログイン
                GIDSignIn.sharedInstance()?.signIn()
            })
            .disposed(by: disposeBag)
        
        registerButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.perform(segue: StoryboardSegue.Login.showRegister, sender: nil)
            })
            .disposed(by: disposeBag)
    }
    
    func login(email: String?, password: String?) {
        guard let email = email, let password = password else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            guard let vc = self else { return }
            if user != nil && error == nil {
                debugPrint("*** login succeeded by Firebase ***")
                vc.perform(segue: StoryboardSegue.Login.showMain, sender: nil)
            } else {
                vc.showAlert(type: .ok, message: L10n.Alert.invalidLoginInfo, completion: {
                    vc.registeringPassword.text = ""
                })
                debugPrint("*** user not found ***")
            }
        }
    }
}

extension LoginViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // login error (include cancel)
        if let error = error {
            debugPrint(error)
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
        Auth.auth().signInAndRetrieveData(with: credential) { [unowned self] (_, error) in
            if let error = error {
                debugPrint(error)
                self.showAlert(type: .ok, title: "認証に失敗しました", message: error.localizedDescription.description)
                return
            }
            debugPrint("*** login succeeded to Firebase by Google ***")
            self.perform(segue: StoryboardSegue.Login.showMain, sender: nil)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        debugPrint("Sign off successfully")
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        registeringEmail.resignFirstResponder()
        registeringPassword.resignFirstResponder()
        return true
    }
}
