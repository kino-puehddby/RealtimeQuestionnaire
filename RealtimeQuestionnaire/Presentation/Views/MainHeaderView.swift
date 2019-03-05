//
//  MainHeaderView.swift
//  RealtimeQuestionnaire
//
//  Created by HisayaSugita on 2019/03/06.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import Reusable

final class MainHeaderView: UIView, NibLoadable {
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var label: UILabel!
    
    func setup(image: UIImage, text: String) {
        imageView.image = image
        label.text = text
    }
}
