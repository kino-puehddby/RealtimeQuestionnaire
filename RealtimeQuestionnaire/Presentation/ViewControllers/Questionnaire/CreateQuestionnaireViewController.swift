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
    @IBOutlet weak private var descriptionField: UITextView!
    @IBOutlet weak private var addCellButton: UIButton!
    @IBOutlet weak private var choicesInvalidLabel: UILabel!
    @IBOutlet weak private var createQuestionnaireButton: UIButton!
    @IBOutlet private var viewTapped: UITapGestureRecognizer!
    
    let choicesList = BehaviorRelay<[String]>(value: [])
    let communities = BehaviorRelay<[[String: String]]>(value: [])
    let viewTap = PublishSubject<Void>()
    let cellTextFieldValid = BehaviorRelay<Bool>(value: false)
    
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
        
        descriptionField.delegate = self
        descriptionField.textContainer.lineBreakMode = .byTruncatingTail
        descriptionField.layer.borderColor = Asset.defaultGray.color.cgColor
        descriptionField.layer.borderWidth = 0.5
        descriptionField.layer.cornerRadius = 5.0
        descriptionField.layer.masksToBounds = true
        
        getUserCommunities()
        
        bindScrollTextFieldWhenShowKeyboard()
    }
    
    func bind() {
        addCellButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.addAction()
            })
            .disposed(by: disposeBag)
        
        createQuestionnaireButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.postQuestionnaire()
            })
            .disposed(by: disposeBag)
        
        communities
            .skip(1)
            .distinctUntilChanged()
            .map { dics in
                dics.map { dic in
                    dic[UsersCommunity.name.rawValue] ?? ""
                }
            }
            .subscribe(onNext: { [unowned self] list in
                self.communityPickerField.setup(dataList: list)
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
        
        let choicesListValid = choicesList
            .map { $0.count >= 2 }
        choicesListValid
            .bind(to: choicesInvalidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        let isValid = Observable
            .combineLatest(
                isTitleFieldValid,
                isCommunityFieldValid,
                choicesListValid,
                cellTextFieldValid
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
                self.descriptionField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        tapEvent
            .bind(to: viewTap)
            .disposed(by: disposeBag)
    }
    
    func getUserCommunities() {
        guard let uid = S.getKeychain(.uid) else { return }
        let documentRef = UserModel.makeDocumentRef(id: uid)
        Firestore.firestore().rx
            .get(
                UserModel.Fields.self,
                documentRef: documentRef
            )
            .subscribe { [unowned self] result in
                switch result {
                case .success(let user):
                    self.communities.accept(user.communities)
                case .error(let error):
                    debugPrint(error)
                    self.communities.accept([])
                }
            }
            .disposed(by: disposeBag)
    }
    
    func postQuestionnaire() {
        guard let uid = S.getKeychain(.uid) else { return }
        let fields = QuestionnaireModel.Fields(
            authorId: uid,
            title: titleField.text ?? "",
            description: descriptionField.text ,
            choices: choicesList.value
        )
        Firestore.firestore().rx
            .setData(
                model: fields,
                collectionRef: QuestionnaireModel.makeCollectionRef()
            )
            .subscribe { [unowned self] result in
                switch result {
                case .success:
                    // FIXME: トースト表示したい
                    self.navigationController?.popViewController(animated: true)
                case .error(let error):
                    self.showAlert(
                        type: .custom,
                        title: L10n.Alert.Questionnaire.failedToCreate,
                        actionTitle: L10n.Common.retry,
                        completion: {
                            self.postQuestionnaire()
                        }
                    )
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func validCells() {
        guard let cells = tableView.visibleCells as? [ChoiceTableViewCell] else { return }
        let invalid = cells.contains { $0.valid.value == false }
        cellTextFieldValid.accept(!invalid)
    }
}

extension CreateQuestionnaireViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choicesList.value.count
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
                var list = self.choicesList.value
                list[row] = text ?? ""
                return list
            }
            .bind(to: choicesList)
            .disposed(by: disposeBag)
        choiceText
            .subscribe(onNext: { [unowned self] _ in
                self.validCells()
            })
            .disposed(by: disposeBag)
        
        viewTap
            .bind(to: cell.viewTap)
            .disposed(by: disposeBag)
    }
    
    private func addAction() {
        tableView.beginUpdates()
        var newList = choicesList.value
        let insertTarget = newList.count
        newList.insert("", at: insertTarget)
        choicesList.accept(newList)
        let indexPath = IndexPath(row: insertTarget, section: 0)
        tableView.insertRows(at: [indexPath], with: .bottom)
        tableView.endUpdates()
    }
    
    private func deleteAction(indexPath: IndexPath) {
        tableView.beginUpdates()
        var newList = choicesList.value
        newList.remove(at: indexPath.row)
        choicesList.accept(newList)
        tableView.deleteRows(at: [indexPath], with: .left)
        tableView.endUpdates()
    }
}

extension CreateQuestionnaireViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            descriptionField.resignFirstResponder()
            return false
        }
        return true
    }
}

extension CreateQuestionnaireViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
