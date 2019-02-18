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
    @IBOutlet weak private var googleSignInButton: GIDSignInButton! // FIXME: サイズがおかしいから直す
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
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        registeringEmail.delegate = self
        registeringPassword.delegate = self
    }
    
    func bind() {
        // TODO: 必要な項目を入力していない時に、アラートを表示する（カスタムクラス化 or Extensionにしちゃっても良さそう）
        
        loginButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.login(email: self.registeringEmail.text, password: self.registeringPassword.text)
            })
            .disposed(by: disposeBag)
        
        googleSignInButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: {
                // 可能な場合はサイレントログイン
                GIDSignIn.sharedInstance()?.signIn()
            })
            .disposed(by: disposeBag)
        
        registerButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.showMain()
            })
            .disposed(by: disposeBag)
    }
    
    func login(email: String?, password: String?) {
        guard let email = email, let password = password else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            guard let vc = self else { return }
            if user != nil && error == nil {
                debugPrint("*** login succeeded by Firebase ***")
                vc.showMain()
            } else if user == nil {
                GIDSignIn.sharedInstance()?.signIn()
            } else {
                debugPrint("*** user not found ***")
            }
        }
    }
    
    func showMain() {
        perform(segue: StoryboardSegue.Login.showMain)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        registeringEmail.resignFirstResponder()
        registeringPassword.resignFirstResponder()
        return true
    }
}

extension LoginViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // ログインエラーの場合（キャンセルも含む）
        if let error = error {
            debugPrint(error)
            return
        }
        guard let authentication = user.authentication else { return }
        
        // TODO: トークンをどこかに保存して、次回以降のログインを省略する
        let credential = GoogleAuthProvider.credential(
            withIDToken: authentication.idToken,
            accessToken: authentication.accessToken
        )
        linkToFirebase(credential: credential)
        
    }
    
    private func linkToFirebase(credential: AuthCredential) {
        // Firebaseにログインする
        Auth.auth().signInAndRetrieveData(with: credential) { [unowned self] (_, error) in
            if let error = error {
                debugPrint(error)
                // ログイン失敗
                debugPrint("*** login failure by Google ***")
                return
            }
            // ログイン成功
            debugPrint("*** login succeeded by Google ***")
            self.showMain()
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        debugPrint("Sign off successfully")
    }
}
