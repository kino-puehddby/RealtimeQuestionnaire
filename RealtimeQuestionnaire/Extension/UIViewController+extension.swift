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
    
    // -----------------------
    // - Set RootViewController
    // -----------------------
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
    
    // -----------------------
    // - Keyboard up & down
    // -----------------------
    func setupKeyboardUpDownWithTextField() {
        let notification = NotificationCenter.default
        notification.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        notification.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    @objc private func keyboardWillShow(_ notification: Notification?) {
        guard let rect = (notification?.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            let transform = CGAffineTransform(translationX: 0, y: -rect.size.height)
            self.view.transform = transform
        }
    }
    @objc private func keyboardWillHide(_ notification: Notification?) {
        guard let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            self.view.transform = CGAffineTransform.identity
        }
    }
}
