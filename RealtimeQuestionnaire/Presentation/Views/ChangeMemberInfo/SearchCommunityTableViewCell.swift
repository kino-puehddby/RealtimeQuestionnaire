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
    
    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
        bind()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // NOTE: メモリリークを防ぐ
        disposeBag = DisposeBag()
    }
    
    private func setup() {
        iconImageView.layer.cornerRadius = iconImageView.bounds.width / 2
        iconImageView.layer.masksToBounds = true
        checkButton.setImage(Asset.nonChecked.image, for: .normal)
    }
    
    private func bind() {
        checkButton.rx.tap.asSignal()
            .emit(onNext: { [unowned self] in
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
