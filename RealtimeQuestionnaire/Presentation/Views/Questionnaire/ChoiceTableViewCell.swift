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

    @IBOutlet weak fileprivate var choiceField: UITextField!
    @IBOutlet weak private var invalidLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    let viewTap = PublishSubject<Void>()
    let valid = BehaviorRelay<Bool>(value: false)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
        bind()
    }
    
    private func setup() {
        choiceField.delegate = self
        choiceField.layer.borderColor = Asset.defaultGray.color.cgColor
        choiceField.layer.borderWidth = 0.5
        choiceField.layer.cornerRadius = 5.0
        choiceField.layer.masksToBounds = true
    }
    
    private func bind() {
        viewTap
            .subscribe(onNext: { [unowned self] in
                self.choiceField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        let textValid = choiceField.rx.text
            .map { $0 != "" && $0 != nil  }
            .share(replay: 1)
        textValid
            .bind(to: valid)
            .disposed(by: disposeBag)
        textValid
            .bind(to: invalidLabel.rx.isHidden)
            .disposed(by: disposeBag)
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
