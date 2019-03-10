//
//  ChangeMemberInfoTableViewCell.swift
//  RealtimeQuestionnaire
//
//  Created by HisayaSugita on 2019/03/02.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Reusable

final class ChangeMemberInfoTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var communityNameLabel: UILabel!
    @IBOutlet weak private var idLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        iconImageView.layer.masksToBounds = true
        iconImageView.layer.cornerRadius = iconImageView.bounds.width / 2
    }
    
    func configure(image: UIImage, communityName: String, id: String) {
        iconImageView.image = image
        communityNameLabel.text = communityName
        idLabel.text = id
    }
}
