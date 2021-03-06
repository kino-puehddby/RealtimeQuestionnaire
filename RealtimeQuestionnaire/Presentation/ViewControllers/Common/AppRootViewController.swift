//
//  AppRootViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/21.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class AppRootViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let splash = StoryboardScene.Splash.initialScene.instantiate()
        addChildVC(splash)
    }
    
    func switchToLoginViewController() {
        guard let currentRootViewController = children.first else { return }
        let loginVC = StoryboardScene.Login.initialScene.instantiate()
        let navigationController = UINavigationController(rootViewController: loginVC)
        addChildVC(navigationController)
        
        currentRootViewController.willMove(toParent: nil)
        currentRootViewController.view.removeFromSuperview()
        currentRootViewController.removeFromParent()
    }
    
    func switchToMainViewController() {
        guard let currentRootViewController = children.first else { return }
        
        let mainVC = StoryboardScene.Main.mainViewController.instantiate()
        let menuVC = StoryboardScene.Menu.menuViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: mainVC)
        
        let slideMenuController = AppSlideMenuController(
            mainViewController: navigationController,
            leftMenuViewController: menuVC
        )
        
        addChildVC(slideMenuController)
        
        currentRootViewController.willMove(toParent: nil)
        currentRootViewController.view.removeFromSuperview()
        currentRootViewController.removeFromParent()
    }
    
    func switchToChangeMemberInfoViewController() {
        guard let currentRootViewController = children.first else { return }
        let changeMemberInfoVC = StoryboardScene.ChangeMemberInfo.initialScene.instantiate()
        changeMemberInfoVC.type = .register
        let navigationController = UINavigationController(rootViewController: changeMemberInfoVC)
        addChildVC(navigationController)
        
        currentRootViewController.willMove(toParent: nil)
        currentRootViewController.view.removeFromSuperview()
        currentRootViewController.removeFromParent()
    }
}
