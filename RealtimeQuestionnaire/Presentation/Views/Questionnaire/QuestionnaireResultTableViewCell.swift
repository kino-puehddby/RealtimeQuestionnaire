//
//  QuestionnaireResultTableViewCell.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/05.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import Reusable

class QuestionnaireResultTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak private var choiceLabel: UILabel!
    @IBOutlet weak private var percentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(choice: String, percent: Double) {
        self.choiceLabel.text = choice
        let rounded = round(percent * 10) / 10
        self.percentLabel.text = rounded.description + " %"
    }
}
