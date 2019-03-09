//
//  SearchCommunityTableViewCell.swift
//  RealtimeQuestionnaire
//
//  Created by HisayaSugita on 2019/03/09.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Reusable

final class SearchCommunityTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var nicknameLabel: UILabel!
    @IBOutlet weak fileprivate var idLabel: UILabel!
    @IBOutlet weak fileprivate var checkButton: UIButton!
    
    var isChecked: Bool = false
    
    private let disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkButton.setImage(Asset.nonChecked.image, for: .normal)
        
        checkButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.checked(!self.isChecked)
            })
            .disposed(by: disposeBag)
    }
    
    func configure(id: String, name: String, iconImage: UIImage) {
        self.idLabel.text = id
        self.nicknameLabel.text = name
        self.iconImageView.image = iconImage
    }
    
    func checked(_ checked: Bool) {
        isChecked = checked
        isChecked ? checkButton.setImage(Asset.checked.image, for: .normal) : checkButton.setImage(Asset.nonChecked.image, for: .normal)
    }
}

extension SearchCommunityTableViewCell {
    var id: String? {
        return idLabel.text
    }
}

extension Reactive where Base: SearchCommunityTableViewCell {
    var checkTapped: Driver<Void> {
        return base.checkButton.rx.tap.asDriver()
    }
}
