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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(image: UIImage, communityName: String, id: String) {
        self.iconImageView.image = image
        communityNameLabel.text = communityName
        // TODO: idを追加
    }
}
