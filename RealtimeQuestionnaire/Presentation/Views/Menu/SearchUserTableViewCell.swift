//
//  SearchUserTableViewCell.swift
//  RealtimeQuestionnaire
//
//  Created by HisayaSugita on 2019/03/03.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Reusable

final class SearchUserTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var nicknameLabel: UILabel!
    @IBOutlet weak fileprivate var checkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure() {
        
    }
}

extension Reactive where Base: SearchUserTableViewCell {
    var checkTapped: Driver<Void> {
        return base.checkButton.rx.tap.asDriver()
    }
}
