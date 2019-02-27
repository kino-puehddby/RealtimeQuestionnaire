//
//  MainViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/18.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import FirebaseAuth
import FirebaseFirestore

final class MainViewController: UIViewController {

    @IBOutlet weak private var leftBarButton: UIBarButtonItem!
    @IBOutlet weak private var rightBarButton: UIBarButtonItem!
    @IBOutlet weak private var tableView: UITableView!
    
    @IBOutlet weak private var createQuestionnaireButton: UIButton!
    @IBOutlet weak private var answerQuestionnaireButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    fileprivate let questionnaireList = BehaviorRelay<[[QuestionnaireModel.Fields]]>(value: [[]])
    let communities = BehaviorRelay<[String]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
    }
    
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: MainTableViewCell.self)
    }
    
    func bind() {
        leftBarButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.slideMenuController()?.openLeft()
            })
            .disposed(by: disposeBag)
        
        rightBarButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.perform(segue: StoryboardSegue.Main.showSearch)
            })
            .disposed(by: disposeBag)
        
        createQuestionnaireButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.perform(segue: StoryboardSegue.Main.showCreateQuestionnaire)
            })
            .disposed(by: disposeBag)
        
        answerQuestionnaireButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.perform(segue: StoryboardSegue.Main.showUnansweredQuestionnaireList)
            })
            .disposed(by: disposeBag)
        
        // observe User
        guard let uid = S.getKeychain(.uid) else { return }
        let userDocumentRef = UserModel.makeDocumentRef(id: uid)
        Firestore.firestore().rx
            .observeModel(
                UserModel.Fields.self,
                documentRef: userDocumentRef
            )
            .subscribe { [weak self] event in
                guard let vc = self else { return }
                switch event {
                case .next(let user):
                    vc.communities.accept(user.communities)
                case .error(let error):
                    debugPrint(error)
                case .completed:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        communities
            .subscribe(onNext: { [weak self] communitieIds in
                guard let vc = self else { return }
                communitieIds.forEach { id in
                    vc.observeQuestionnaire(on: id)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func observeQuestionnaire(on communityId: String) {
        // observe Questionnaire
        Firestore.firestore().rx
            .observeArray(
                QuestionnaireModel.Fields.self,
                collectionRef: CommunityModel.makeCollectionRef().document(communityId).collection(CollectionKey.questionnaire.rawValue)
            )
            .subscribe { [weak self] event in
                guard let vc = self else { return }
                switch event {
                case .next(let list):
                    debugPrint(list)
                    var oldList = vc.questionnaireList.value
                    let newList = oldList.append(list)
                    vc.questionnaireList.accept(newList)
                    vc.tableView.reloadData()
                case .error(let error):
                    debugPrint(error)
                case .completed:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionnaireList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MainTableViewCell.self)
        let data = questionnaireList.value[indexPath.row]
        let title = data.title
        let description = data.description ?? ""
        cell.configuration(
            // FIXME: 画像をFirebase Storageから取得するようにする
            iconImage: Asset.sample.image,
            title: title,
            description: description)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Main.TableView.cellHeight
    }
}
