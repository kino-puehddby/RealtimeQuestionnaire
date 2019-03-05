//
//  AnswerQuestionnaireViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/04.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

final class AnswerQuestionnaireViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var communityIconImageView: UIImageView!
    @IBOutlet weak private var communityNameLabel: UILabel!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var authorNameLabel: UILabel!
    @IBOutlet weak private var answerButton: UIButton!
    
    lazy var data: QuestionnaireModel.Fields = { preconditionFailure() }()
    
    private lazy var viewModel: AnswerQuestionnaireViewModel = { preconditionFailure() }()
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
    }
    
    func setup() {
        viewModel = AnswerQuestionnaireViewModel(questionnaireData: data)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: AnswerQuestionnaireTableViewCell.self)
        
        titleLabel.text = data.title
    }
    
    func bind() {
        viewModel.communityIconImage
            .bind(to: communityIconImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.communityName
            .bind(to: communityNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.authorName
            .bind(to: authorNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.answerCompleted
            .subscribe(onNext: { [unowned self] status in
                switch status {
                case .success:
                    guard let navi = self.navigationController else { return }
                    navi.popViewController(animated: true)
                case .error(let error):
                    debugPrint(error)
                }
            })
            .disposed(by: disposeBag)
        
        answerButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                guard let cells = self.tableView.visibleCells as? [AnswerQuestionnaireTableViewCell] else { return }
                for (index, cell) in cells.enumerated() where cell.isChecked {
                    self.viewModel.answer(index: index)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension AnswerQuestionnaireViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.choices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: AnswerQuestionnaireTableViewCell.self)
        cell.configure(choice: data.choices[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return QuestionnaireDetail.AnswerQuestionnaire.TableView.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cells = tableView.visibleCells as? [AnswerQuestionnaireTableViewCell] else { return }
        // 選択肢は一つのみ回答可能
        for (index, cell) in cells.enumerated() {
            if index == indexPath.row {
                cell.check(true)
            } else {
                cell.check(false)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}