//
//  SplashViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/18.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import FirebaseAuth
import GoogleSignIn

final class SplashViewController: UIViewController, GIDSignInUIDelegate {
    
    lazy var handle: AuthStateDidChangeListenerHandle = { preconditionFailure() }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    private func setup() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            guard let vc = self else { return }
            if user != nil {
                vc.switchMainViewController()
            } else {
                vc.switchLoginViewController()
            }
        }
    }
    
    private func signInFirebase(with credential: AuthCredential) {
        Auth.auth().signInAndRetrieveData(with: credential) { [unowned self] (_, error) in
            if let error = error {
                debugPrint("*** login failure to Firebase by Google: \(error) ***")
                self.showAlert(type: .ok, title: L10n.Alert.Auth.failure, message: error.localizedDescription.description)
                return
            }
            self.switchMainViewController()
        }
    }
}
