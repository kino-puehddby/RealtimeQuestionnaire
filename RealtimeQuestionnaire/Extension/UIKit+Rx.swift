//
//  UIKit+Rx.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/04.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SVProgressHUD

extension Reactive where Base: UIViewController {
    
    var viewWillAppear: Observable<Void> {
        return sentMessage(#selector(base.viewWillAppear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }
    
    var viewDidDisappear: Observable<Void> {
        return sentMessage(#selector(base.viewDidDisappear(_:)))
            .map { _ in () }
            .share(replay: 1)
    }
    
    var hud: Binder<Bool> {
        return Binder(base) { _, isLoading in
            isLoading ? SVProgressHUD.show() : SVProgressHUD.dismiss(withDelay: 0.3)
        }
    }
}
