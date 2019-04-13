//
//  AppDelegate.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/18.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import Firebase
import GoogleSignIn
import SlideMenuControllerSwift
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var photoLibraryImage: UIImage!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Firebase
        FirebaseApp.configure()
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        
        // SlideMenuController
        window?.rootViewController = AppRootViewController()
        
        // SVProgressHUD
        SVProgressHUD.setDefaultMaskType(.clear)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String
        if GIDSignIn.sharedInstance()?.handle(url, sourceApplication: sourceApplication, annotation: [:]) != nil {
            return true
        }
        return false
    }
}
