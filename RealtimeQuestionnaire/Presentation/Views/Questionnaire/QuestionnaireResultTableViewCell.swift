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

    @IBOutlet weak private var colorView: UIView!
    @IBOutlet weak private var choiceLabel: UILabel!
    @IBOutlet weak private var percentLabel: UILabel!
    
    func configure(color: UIColor, choice: String, percent: Double) {
        choiceLabel.text = choice
        let rounded = round(percent * 10) / 10
        percentLabel.text = rounded.description + " %"
        colorView.backgroundColor = color
    }
}
