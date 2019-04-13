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
    @IBOutlet weak fileprivate var idLabel: UILabel!
    @IBOutlet weak fileprivate var checkButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkButton.setImage(Asset.nonChecked.image, for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // NOTE: メモリリークを防ぐ
        disposeBag = DisposeBag()
    }
    
    func configure(id: String, nickname: String, iconImage: UIImage) {
        self.idLabel.text = id
        self.nicknameLabel.text = nickname
        self.iconImageView.image = iconImage
    }
    
    func checked(_ checked: Bool) {
        checked ? checkButton.setImage(Asset.checked.image, for: .normal) : checkButton.setImage(Asset.nonChecked.image, for: .normal)
    }
}

extension SearchUserTableViewCell {
    var id: String? {
        return idLabel.text
    }
}

extension Reactive where Base: SearchUserTableViewCell {
    var checkTapped: Driver<Void> {
        return base.checkButton.rx.tap.asDriver()
    }
}
