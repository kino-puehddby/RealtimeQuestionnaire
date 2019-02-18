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
        
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
        
        // リスナーをアタッチ。ユーザーのログイン状態が変わるたびに呼び出される。
        handle = Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            guard let vc = self else { return }
            if user != nil {
                vc.perform(segue: StoryboardSegue.Splash.showMain)
            } else {
                vc.perform(segue: StoryboardSegue.Splash.showLogin)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // リスナーをデタッチ
        Auth.auth().removeStateDidChangeListener(handle)
    }
}
