//
//  CreateQuestionnaireViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/20.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import FirebaseAuth
import FirebaseFirestore

final class CreateQuestionnaireViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var titleField: UITextField!
    @IBOutlet weak private var titleInvalidLabel: UILabel!
    @IBOutlet weak private var communityPickerField: PickerTextField!
    @IBOutlet weak private var communityInvalidLabel: UILabel!
    @IBOutlet weak private var addCellButton: UIButton!
    @IBOutlet weak private var choicesInvalidLabel: UILabel!
    @IBOutlet weak private var createQuestionnaireButton: UIButton!
    @IBOutlet private var viewTapped: UITapGestureRecognizer!
    
    fileprivate let viewModel = CreateQuestionnaireViewModel()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
    }
    
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: ChoiceTableViewCell.self)
        
        titleField.delegate = self
        communityPickerField.delegate = self
        
        bindScrollTextFieldWhenShowKeyboard()
    }
    
    func bind() {
        addCellButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.addAction()
            })
            .disposed(by: disposeBag)
        
        communityPickerField.rx.text.orEmpty
            .distinctUntilChanged()
            .map { [unowned self] selected in
                // 選択されたコミュニティ名をコミュニティIDに変換する
                let targetIndex: Int? = {
                    for (index, community) in self.viewModel.communities.value.enumerated() where community["name"] == selected {
                        return index
                    }
                    return nil
                }()
                guard let index = targetIndex else { return "" }
                return self.viewModel.communities.value[index]["id"] ?? ""
            }
            .bind(to: viewModel.selectedCommunityId)
            .disposed(by: disposeBag)
        
        createQuestionnaireButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                guard let uid = S.getKeychain(.uid) else { return }
                let fields = QuestionnaireModel.Fields(
                    id: "",
                    authorId: uid,
                    title: self.titleField.text ?? "",
                    choices: self.viewModel.choicesList.value
                )
                self.viewModel.postQuestionnaire(fields: fields)
            })
            .disposed(by: disposeBag)
        
        viewModel.communities
            .skip(1)
            .distinctUntilChanged()
            .map { dics in
                dics.map { dic in
                    dic["name"] ?? ""
                }
            }
            .subscribe(onNext: { [unowned self] list in
                self.communityPickerField.setup(dataList: list)
            })
            .disposed(by: disposeBag)
        
        viewModel.postCompleted
            .subscribe(onNext: { [unowned self] status in
                switch status {
                case .success:
                    // FIXME: トースト表示したい
                    self.navigationController?.popViewController(animated: true)
                case .error(let error):
                    self.showAlert(
                        type: .custom,
                        title: L10n.Alert.Questionnaire.failedToCreate,
                        actionTitle: L10n.Common.retry
                    )
                    debugPrint(error)
                }
            })
            .disposed(by: disposeBag)
        
        let isTitleFieldValid = titleField.rx.text
            .distinctUntilChanged()
            .map { $0 != "" && $0 != nil }
            .share(replay: 1)
        isTitleFieldValid
            .bind(to: titleInvalidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        let isCommunityFieldValid = communityPickerField.rx.text
            .distinctUntilChanged()
            .map { $0 != "" && $0 != nil }
            .share(replay: 1)
        isCommunityFieldValid
            .bind(to: communityInvalidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        let choicesListValid = viewModel.choicesList
            .map { $0.count >= 2 }
        choicesListValid
            .bind(to: choicesInvalidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        let isValid = Observable
            .combineLatest(
                isTitleFieldValid,
                isCommunityFieldValid,
                choicesListValid,
                viewModel.cellTextFieldValid
            )
            .map { $0 && $1 && $2 && $3 }
            .share(replay: 1)
        isValid
            .bind(to: createQuestionnaireButton.rx.isEnabled)
            .disposed(by: disposeBag)
        isValid
            .subscribe(onNext: { [unowned self] isValid in
                self.createQuestionnaireButton.backgroundColor = isValid ? Asset.systemBlue.color : .lightGray
            })
            .disposed(by: disposeBag)
        
        let tapEvent = viewTapped.rx.event
            .map { _ in }
            .share(replay: 1)
        tapEvent
            .subscribe(onNext: { [unowned self] in
                self.titleField.resignFirstResponder()
                self.communityPickerField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        tapEvent
            .bind(to: viewModel.viewTap)
            .disposed(by: disposeBag)
    }
    
    func validCells() {
        guard let cells = tableView.visibleCells as? [ChoiceTableViewCell] else { return }
        let invalid = cells.contains { $0.valid.value == false }
        viewModel.cellTextFieldValid.accept(!invalid)
    }
}

extension CreateQuestionnaireViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.choicesList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ChoiceTableViewCell.self)
        bind(cell: cell, row: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CreateQuestionnaire.TableView.cellHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] (_, indexPath) in
            self.deleteAction(indexPath: indexPath)
        }
        return [delete]
    }
    
    private func bind(cell: ChoiceTableViewCell, row: Int) {
        let choiceText = cell.rx.choiceText
            .distinctUntilChanged()
            .share(replay: 1)
        choiceText
            .map { [unowned self] text in
                var list = self.viewModel.choicesList.value
                list[row] = text ?? ""
                return list
            }
            .bind(to: viewModel.choicesList)
            .disposed(by: disposeBag)
        choiceText
            .subscribe(onNext: { [unowned self] _ in
                self.validCells()
            })
            .disposed(by: disposeBag)
        
        viewModel.viewTap
            .bind(to: cell.viewTap)
            .disposed(by: disposeBag)
    }
    
    private func addAction() {
        tableView.beginUpdates()
        var newList = viewModel.choicesList.value
        let insertTarget = newList.count
        newList.insert("", at: insertTarget)
        viewModel.choicesList.accept(newList)
        let indexPath = IndexPath(row: insertTarget, section: 0)
        tableView.insertRows(at: [indexPath], with: .bottom)
        tableView.endUpdates()
    }
    
    private func deleteAction(indexPath: IndexPath) {
        tableView.beginUpdates()
        var newList = viewModel.choicesList.value
        newList.remove(at: indexPath.row)
        viewModel.choicesList.accept(newList)
        tableView.deleteRows(at: [indexPath], with: .left)
        tableView.endUpdates()
    }
}

extension CreateQuestionnaireViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
