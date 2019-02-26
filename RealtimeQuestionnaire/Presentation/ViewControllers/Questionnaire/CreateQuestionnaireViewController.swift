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
    @IBOutlet weak private var communityPickerField: PickerTextField!
    @IBOutlet weak private var descriptionField: UITextView!
    @IBOutlet weak private var addCellButton: UIButton!
    @IBOutlet weak private var createQuestionnaireButton: UIButton!
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        titleField.resignFirstResponder()
        communityPickerField.resignFirstResponder()
        descriptionField.resignFirstResponder()
    }
    
    let choicesList = BehaviorRelay<[String]>(value: [])
    let communities = BehaviorRelay<[String]>(value: [])
    
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
        
        descriptionField.delegate = self
        descriptionField.textContainer.lineBreakMode = .byTruncatingTail
        descriptionField.layer.borderColor = Asset.defaultGray.color.cgColor
        descriptionField.layer.borderWidth = 0.5
        descriptionField.layer.cornerRadius = 5.0
        descriptionField.layer.masksToBounds = true
        
        addCellButton.layer.cornerRadius = addCellButton.bounds.width / 2
        addCellButton.layer.masksToBounds = true
        
        getUserCommunities()
        
        setupKeyboardUpDownWithTextField()
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
            .subscribe(onNext: { [unowned self] list in
                self.communityPickerField.setup(dataList: list)
            })
            .disposed(by: disposeBag)
    }
    
    func getUserCommunities() {
        guard let user = Auth.auth().currentUser else { return } // UserDefaultかKeyChainに保存しておく
        let documentRef = UserModel.makeDocumentRef(id: user.uid)
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
        guard let user = Auth.auth().currentUser else { return }
        let fields = QuestionnaireListModel.Fields(
            authorId: user.uid,
            title: titleField.text ?? "",
            description: descriptionField.text,
            communityName: communityPickerField.text ?? "",
            choices: choicesList.value
        )
        Firestore.firestore().rx
            .setData(
                model: fields,
                collectionRef: QuestionnaireListModel.makeCollectionRef()
            )
            .subscribe { [unowned self] result in
                switch result {
                case .success(()):
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
}

extension CreateQuestionnaireViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choicesList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ChoiceTableViewCell.self)
        cell.configure(row: indexPath.row)
        cell.rx.choiceText.asObservable()
            .map { [unowned self] text in
                var list = self.choicesList.value
                list[indexPath.row] = text ?? ""
                return list
            }
            .bind(to: choicesList)
            .disposed(by: disposeBag)
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
    
    func addAction() {
        tableView.beginUpdates()
        var newList = choicesList.value
        newList.insert("", at: 0)
        choicesList.accept(newList)
        tableView.insertRows(at: [[0, 0]], with: .bottom)
        tableView.endUpdates()
    }
    
    func deleteAction(indexPath: IndexPath) {
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
