//
//  TrimImageViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/01.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

final class TrimImageViewController: UIViewController {

    @IBOutlet weak private var trimRangeVIew: UIView!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var decideButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    var postDissmissionAction: (() -> Void)?
    
    private var image: UIImage!
    
    private var scaleZoomedInOut: CGFloat = 1.0
    
    private var pichCenter: CGPoint!
    private var touchPoint1: CGPoint!
    private var touchPoint2: CGPoint!
    private let maxScale: CGFloat = 1
    private var pinchStartImageCenter: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        image = appDelegate.photoLibraryImage
        createImageView(sourceImage: image, on: trimRangeVIew)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let aTouch: UITouch = touches.first!
        
        let location = aTouch.location(in: trimRangeVIew)
        
        let preLocation = aTouch.previousLocation(in: trimRangeVIew)
        
        let deltaX = location.x - preLocation.x
        let deltaY = location.y - preLocation.y
        
        imageView.frame.origin.x += deltaX
        imageView.frame.origin.y += deltaY
    }
    
    func setup() {
        trimRangeVIew.layer.borderColor = UIColor.white.cgColor
        trimRangeVIew.layer.borderWidth = 1
        setupPinchInOut()
    }
    
    func bind() {
        decideButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                if let trimmingRect = self.makeTrimmingRect(
                    targetImageView: self.imageView,
                    trimmingAreaView: self.trimRangeVIew
                    ) {
                    self.image = self.image.trimming(trimmingArea: trimmingRect)
                    self.saveImage()
                    self.dismiss()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setupPinchInOut() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(gesture:)))
        pinchGesture.delegate = self
        
        trimRangeVIew.isUserInteractionEnabled = true
        trimRangeVIew.addGestureRecognizer(pinchGesture)
    }
    
    func saveImage() {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.photoLibraryImage = image
    }
    
    func dismiss() {
        dismiss(animated: true) { [weak self] in
            self?.postDissmissionAction?()
        }
    }
    
    func createImageView(sourceImage: UIImage, on parentView: UIView) {
        imageView.image = sourceImage
        
        let imageWidth = sourceImage.size.width
        let imageHeight = sourceImage.size.height
        let trimRangeWidth = trimRangeVIew.frame.width
        let trimRangeHeight = trimRangeVIew.frame.height
        
        if scaleZoomedInOut == 1.0 {
            if imageWidth > trimRangeWidth {
                scaleZoomedInOut = trimRangeWidth / imageWidth
            }
        }
        
        let rect = CGRect(
            x: 0,
            y: 0,
            width: scaleZoomedInOut * imageWidth,
            height: scaleZoomedInOut * imageHeight
        )
        // ImageView frame をCGRectで作った矩形に合わせる
        imageView.frame = rect
        
        // 画像の中心をスクリーンの中心位置に設定
        imageView.center = CGPoint(x: trimRangeWidth/2, y: trimRangeHeight/2)
        
        parentView.addSubview(imageView)
        parentView.sendSubviewToBack(imageView)
    }
    
    func makeTrimmingRect(targetImageView: UIImageView, trimmingAreaView: UIView) -> CGRect? {
        var width = CGFloat()
        var height = CGFloat()
        var trimmingX = CGFloat()
        var trimmingY = CGFloat()
        
        let deltaX = targetImageView.frame.origin.x
        let deltaY = targetImageView.frame.origin.y
        
        var xNotTrimFlag = false
        //x方向
        if targetImageView.frame.width > trimmingAreaView.frame.width {
            
            //3. 最初の時点で画面のy方向に画像がはみ出している時
            if targetImageView.frame.origin.x > 0 {
                //origin.y > 0の場合、確実にy方向に画面から外れている
                //上方向にはみ出し
                width = trimmingAreaView.frame.size.width - deltaX
            } else {
                //origin.y < 0の場合、上方向には確実にはみ出している
                //下方向がはみ出していない
                if trimmingAreaView.frame.size.width > (targetImageView.frame.size.width + targetImageView.frame.origin.x) {
                    width = targetImageView.frame.size.width + targetImageView.frame.origin.x
                } else {
                    //下方向もはみ出し
                    width = trimmingAreaView.frame.size.width
                }
            }
        } else {
            //4. 最初の時点で画面のy方向に画像がすっぽり全て収まっている時
            if targetImageView.frame.origin.x > 0 {
                if trimmingAreaView.frame.size.width < (targetImageView.frame.size.width + targetImageView.frame.origin.x) {
                    //下方向にはみ出し
                    width = trimmingAreaView.frame.size.width - deltaX
                } else {
                    xNotTrimFlag = true
                    width = targetImageView.frame.size.width
                }
            } else {
                //上方向にはみ出し
                width = targetImageView.frame.size.width + targetImageView.frame.origin.x
            }
        }
        //y方向
        if targetImageView.frame.height > trimmingAreaView.frame.height {
            
            //3. 最初の時点で画面のy方向に画像がはみ出している時
            if targetImageView.frame.origin.y > 0 {
                //origin.y > 0の場合、確実にy方向に画面から外れている
                //下方向にはみ出し
                height = trimmingAreaView.frame.size.height - deltaY
            } else {
                //origin.y < 0の場合、上方向には確実にはみ出している
                //下方向がはみ出していない
                if trimmingAreaView.frame.size.height > (targetImageView.frame.size.height + targetImageView.frame.origin.y) {
                    height = targetImageView.frame.size.height + targetImageView.frame.origin.y
                } else {
                    //下方向もはみ出し
                    height = trimmingAreaView.frame.size.height
                }
            }
        } else {
            //4. 最初の時点で画面のy方向に画像がすっぽり全て収まっている時
            if targetImageView.frame.origin.y > 0 {
                if trimmingAreaView.frame.size.height < (targetImageView.frame.size.height + targetImageView.frame.origin.y) {
                    //下方向にはみ出し
                    height = trimmingAreaView.frame.size.height - deltaY
                } else {
                    if xNotTrimFlag {
                        return nil
                    } else {
                        height = targetImageView.frame.size.height
                    }
                }
            } else {
                //上方向にはみ出し
                height = targetImageView.frame.size.height + targetImageView.frame.origin.y
            }
        }
        
        //trimmingRectの座標を決定
        if targetImageView.frame.origin.x > trimmingAreaView.frame.origin.x {
            trimmingX = 0
        } else {
            trimmingX = -deltaX
        }
        
        if targetImageView.frame.origin.y > 0 {
            trimmingY = 0
        } else {
            trimmingY = -deltaY
        }
        
        return CGRect(x: trimmingX, y: trimmingY, width: width, height: height)
    }
}

extension TrimImageViewController: UIGestureRecognizerDelegate {
    
    @objc func pinchAction(gesture: UIPinchGestureRecognizer) {
        
        if gesture.state == UIGestureRecognizer.State.began {
            // ピンチを開始したときの画像の中心点を保存しておく
            pinchStartImageCenter = imageView.center
            touchPoint1 = gesture.location(ofTouch: 0, in: self.view)
            touchPoint2 = gesture.location(ofTouch: 1, in: self.view)
            
            // 指の中間点を求めて保存しておく
            // UIGestureRecognizerState.Changedで毎回求めた場合、ピンチ状態で片方の指だけ動かしたときに中心点がずれておかしな位置でズームされるため
            pichCenter = CGPoint(
                x: (touchPoint1.x + touchPoint2.x) / 2,
                y: (touchPoint1.y + touchPoint2.y) / 2
            )
            
        } else if gesture.state == UIGestureRecognizer.State.changed {
            // ピンチジェスチャー・変更中
            var pinchScale: CGFloat// ピンチを開始してからの拡大率。差分ではない
            if gesture.scale > 1 {
                pinchScale = 1 + gesture.scale/100
            } else {
                pinchScale = gesture.scale
            }
            if pinchScale * imageView.frame.width < trimRangeVIew.frame.width {
                pinchScale = trimRangeVIew.frame.width / imageView.frame.width
            }
            scaleZoomedInOut *= pinchScale
            
            // ピンチした位置を中心としてズーム（イン/アウト）するように、画像の中心位置をずらす
            let newCenter = CGPoint(
                x: pinchStartImageCenter.x - ((pichCenter.x - pinchStartImageCenter.x) * pinchScale - (pichCenter.x - pinchStartImageCenter.x)),
                y: pinchStartImageCenter.y - ((pichCenter.y - pinchStartImageCenter.y) * pinchScale - (pichCenter.y - pinchStartImageCenter.y))
            )
            self.imageView.frame.size = CGSize(
                width: pinchScale * imageView.frame.width,
                height: pinchScale * imageView.frame.height
            )
            imageView.center = newCenter
        }
    }
}
