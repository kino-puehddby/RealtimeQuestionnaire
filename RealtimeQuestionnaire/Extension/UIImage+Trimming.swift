//
//  UIImage+Trimming.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/01.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

extension UIImage {
    func trimming(trimmingArea: CGRect) -> UIImage {
        let imageRef = self.cgImage?.cropping(to: trimmingArea)
        let trimImage = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return trimImage
    }
}
