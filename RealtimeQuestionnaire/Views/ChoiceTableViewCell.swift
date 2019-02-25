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

    @IBOutlet weak private var choiceField: UITextView!
    @IBOutlet weak private var addButton: UIButton!
    
    private let disposeBag = DisposeBag()
    let addTrigger = PublishSubject<Void>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
        bind()
    }
    
    private func setup() {
        choiceField.delegate = self
        choiceField.textContainer.maximumNumberOfLines = 2
        choiceField.textContainer.lineBreakMode = .byTruncatingTail
    }
    
    private func bind() {
        addButton.rx.tap
            .bind(to: addTrigger)
            .disposed(by: disposeBag)
        
        choiceField.rx.text.orEmpty
            .subscribe(onNext: { [unowned self] text in
                self.validTextLength(text: text)
            })
            .disposed(by: disposeBag)
    }
    
    func configure() {
        
    }
    
    private func validTextLength(text: String) {
//        if text.lengthOfBytes(using: .utf8) > 200 {
//            choiceField.resignFirstResponder()
//        }
    }
}

extension ChoiceTableViewCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.lengthOfBytes(using: .utf8) > 100 {
            choiceField.text = String(choiceField.text.prefix(100))
            return false
        }
        if text == "\n" {
            choiceField.resignFirstResponder()
        }
        return true
    }
}
