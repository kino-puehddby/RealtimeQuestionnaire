//
//  ChoiceTableViewCell.swift
//  RealtimeQuestionnaire
//
//  Created by HisayaSugita on 2019/02/24.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import Reusable
import RxSwift
import RxCocoa

final class ChoiceTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak private var rowLabel: UILabel!
    @IBOutlet weak fileprivate var choiceField: UITextView!
    
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        choiceField.delegate = self
        choiceField.textContainer.maximumNumberOfLines = 2
        choiceField.textContainer.lineBreakMode = .byTruncatingTail
        choiceField.textContainer.lineBreakMode = .byTruncatingTail
        choiceField.layer.borderColor = Asset.defaultGray.color.cgColor
        choiceField.layer.borderWidth = 0.5
        choiceField.layer.cornerRadius = 5.0
        choiceField.layer.masksToBounds = true
    }
    
    func configure(row: Int) {
        rowLabel.text = "選択肢\(row)"
    }
}

extension ChoiceTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            choiceField.resignFirstResponder()
            return false
        }
        return true
    }
}

extension ChoiceTableViewCell {
    var choiceText: String {
        return choiceField.text
    }
}

extension Reactive where Base: ChoiceTableViewCell {
    var choiceText: ControlProperty<String?> {
        return base.choiceField.rx.text
    }
}
