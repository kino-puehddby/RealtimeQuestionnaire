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
    @IBOutlet weak fileprivate var choiceField: UITextField!
    
    private let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        choiceField.delegate = self
        choiceField.layer.borderColor = Asset.defaultGray.color.cgColor
        choiceField.layer.borderWidth = 0.5
        choiceField.layer.cornerRadius = 5.0
        choiceField.layer.masksToBounds = true
    }
    
    func configure(row: Int) {
        rowLabel.text = L10n.Questionnaire.Create.Choice.value(row + 1)
    }
}

extension ChoiceTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        choiceField.resignFirstResponder()
        return true
    }
}

extension Reactive where Base: ChoiceTableViewCell {
    var choiceText: ControlProperty<String?> {
        return base.choiceField.rx.text
    }
}
