//
//  CreateCommunityTableViewCell.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/01.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import Reusable

final class CreateCommunityTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak private var profileImageView: UIImageView!
    @IBOutlet weak private var nicknameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
