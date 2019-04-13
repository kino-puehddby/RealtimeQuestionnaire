//
//  AnswerQuestionnaireTableViewCell.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/04.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import Reusable

final class AnswerQuestionnaireTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak private var choiceLabel: UILabel!
    @IBOutlet weak private var checkImage: UIImageView!
    
    var isChecked: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(choice: String) {
        choiceLabel.text = choice
    }
    
    func check(_ isChecked: Bool) {
        self.isChecked = isChecked
        checkImage.image = isChecked ? Asset.checked.image : Asset.nonChecked.image
    }
}
