//
//  UIViewController+extension.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/21.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit
import SnapKit

extension UIViewController {
    
    func switchLoginViewController() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let rootViewController = appDelegate.window?.rootViewController as? AppRootViewController else { return }
        rootViewController.switchToLoginViewController()
    }
    
    func switchMainViewController() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let rootViewController = appDelegate.window?.rootViewController as? AppRootViewController else { return }
        rootViewController.switchToMainViewController()
    }
    
    func addChildVC(_ vc: UIViewController) {
        addChild(vc)
        view.addSubview(vc.view)
        vc.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        vc.didMove(toParent: self)
    }
}
