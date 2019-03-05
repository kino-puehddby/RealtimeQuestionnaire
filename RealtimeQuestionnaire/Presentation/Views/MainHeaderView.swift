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
    
    func set(image: UIImage) {
        imageView.image = image
    }
    
    func set(text: String) {
        label.text = text
    }
}
