//
//  AppSlideMenuController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/21.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import SlideMenuControllerSwift

final class AppSlideMenuController: SlideMenuController, SlideMenuControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SlideMenuOptions.simultaneousGestureRecognizers = false
        SlideMenuOptions.contentViewScale = 1
        delegate = self
    }
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return mainViewController?.preferredStatusBarStyle ?? .default
    }
}
