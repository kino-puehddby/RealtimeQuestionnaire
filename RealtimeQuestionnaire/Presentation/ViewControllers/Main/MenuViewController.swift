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
                self.logout()
            })
            .disposed(by: disposeBag)
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            showAlert(type: .okCancel, title: L10n.Alert.logout, message: L10n.Alert.Logout.message) { [weak self] in
                guard let vc = self else { return }
                vc.switchLoginViewController()
            }
        } catch {
            print("*** failed to sign out ***")
        }
    }
}
