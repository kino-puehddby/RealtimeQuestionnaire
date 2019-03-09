//
//  PhotoLibraryManager.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/01.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit
import Photos

struct PhotoLibraryManager {
    
    var parentViewController: UIViewController!
    
    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }
    
    // 写真へのアクセスがOFFのときに使うメソッド
    func requestAuthorizationOn() {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.denied {
            let alert = UIAlertController(
                title: L10n.Alert.RequestPictureAuth.title,
                message: L10n.Alert.RequestPictureAuth.subTitle,
                preferredStyle: .alert
            )
            let settingsAction = UIAlertAction(title: L10n.Alert.RequestPictureAuth.actionTitle, style: .default) { (_) -> Void in
                guard URL(string: UIApplication.openSettingsURLString) != nil else {
                    return
                }
            }
            alert.addAction(settingsAction)
            alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
            self.parentViewController.present(alert, animated: true)
        }
    }
    
    func callPhotoLibrary() {
        // 権限の確認
        requestAuthorizationOn()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            
            let picker = UIImagePickerController()
            picker.modalPresentationStyle = UIModalPresentationStyle.popover
            picker.delegate = self.parentViewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            // 写真選択後にiOSデフォルトのトリミングViewが開くようになる
            if let popover = picker.popoverPresentationController {
                popover.sourceView = self.parentViewController.view
                popover.sourceRect = self.parentViewController.view.frame
                popover.permittedArrowDirections = UIPopoverArrowDirection.any
            }
            self.parentViewController.present(picker, animated: true, completion: nil)
        }
    }
}
