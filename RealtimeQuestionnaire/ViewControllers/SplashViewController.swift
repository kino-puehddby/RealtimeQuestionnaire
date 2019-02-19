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

class SplashViewController: UIViewController, GIDSignInUIDelegate {
    
    lazy var handle: AuthStateDidChangeListenerHandle = { preconditionFailure() }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handle = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            guard let vc = self else { return }
            if user != nil {
                // SwiftGenでinstantiateするとnavigationControllerになってしまうので、原始的な方法で対応
                let storyboard = UIStoryboard(name: StoryboardScene.Main.storyboardName, bundle: nil)
                let mainVC = storyboard.instantiateViewController(withIdentifier: StoryboardScene.Main.storyboardName)
                vc.present(mainVC, animated: false)
            } else {
                let loginVC = StoryboardScene.Login.initialScene.instantiate()
                vc.present(loginVC, animated: false)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle)
    }
    
    private func signInFirebase(with credential: AuthCredential) {
        Auth.auth().signInAndRetrieveData(with: credential) { [unowned self] (_, error) in
            if let error = error {
                debugPrint("*** login failure to Firebase by Google: \(error) ***")
                self.showAlert(type: .ok, title: L10n.Alert.Auth.failure, message: error.localizedDescription.description)
                return
            }
            debugPrint("*** login succeeded to Firebase by Google ***")
            self.perform(segue: StoryboardSegue.Splash.showMain, sender: nil)
        }
    }
}
