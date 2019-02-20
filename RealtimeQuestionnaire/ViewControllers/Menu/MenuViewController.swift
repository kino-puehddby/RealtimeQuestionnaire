//
//  MenuViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/20.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import FirebaseAuth

final class MenuViewController: UIViewController {
    
    @IBOutlet weak private var logoutButton: UIButton!
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        logoutButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                // TODO: アラートで確認する
                self.logout()
            })
            .disposed(by: disposeBag)
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            let loginVC = StoryboardScene.Login.initialScene.instantiate()
            guard let navi = navigationController else { return }
            navi.setViewControllers([loginVC], animated: false)
        } catch {
            print("*** failed to sign out ***")
        }
    }
}
