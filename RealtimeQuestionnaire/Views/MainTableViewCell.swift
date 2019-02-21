//
//  MainTableViewCell.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/21.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit
import Reusable

class MainTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.layer.masksToBounds = true
        iconImageView.layer.cornerRadius = iconImageView.bounds.width / 2
    }
    
    func configuration(iconImage: UIImage, name: String, description: String) {
        iconImageView.image = iconImage
        nameLabel.text = name
        descriptionLabel.text = description
    }
}
