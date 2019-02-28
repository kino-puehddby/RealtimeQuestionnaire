//
//  MenuTableViewCell.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/28.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import Reusable

class MenuTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak private var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(text: String) {
        label.text = text
    }
}
