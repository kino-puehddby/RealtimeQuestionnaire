//
//  UIViewController+UIKit.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/19.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(type: AlertType, title: String? = nil, message: String? = nil, actionTitle: String? = nil, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: L10n.Common.ok, style: .default) {  _ in
            completion?()
        }
        alert.addAction(okAction)
        switch type {
        case .ok:
            break
        case .okCancel:
            let cancelAction = UIAlertAction(title: L10n.Common.cancel, style: .cancel)
            alert.addAction(cancelAction)
        case .custom:
            let customAction = UIAlertAction(title: actionTitle, style: .default) {  _ in
                completion?()
            }
            alert.addAction(customAction)
        }
        present(alert, animated: true)
    }
}

enum AlertType {
    case ok
    case okCancel
    case custom
}
