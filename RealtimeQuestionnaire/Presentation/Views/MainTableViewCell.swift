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

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var unansweredFlug: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configuration(title: String, answered: Bool) {
        titleLabel.text = title
        unansweredFlug.isHidden = answered
    }
}
