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
    
    private let refreshControl = UIRefreshControl()
    
    fileprivate let questionnaireList = BehaviorRelay<[QuestionnaireListModel.Fields]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableViewに参加中のアンケート一覧を表示する
        
        setup()
        bind()
    }
    
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: MainTableViewCell.self)
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
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
        
        // observe QuestionnaireList on Firestore
        Firestore.firestore().rx
            .observeArray(
                QuestionnaireListModel.Fields.self,
                collectionRef: QuestionnaireListModel.makeCollectionRef()
            )
            .subscribe { [weak self] event in
                guard let vc = self else { return }
                switch event {
                case .next(let list):
                    vc.questionnaireList.accept(list)
                    vc.tableView.reloadData()
                case .error(let error):
                    debugPrint(error)
                case .completed:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        Firestore.firestore().rx
            .getArray(
                QuestionnaireListModel.Fields.self,
                collectionRef: QuestionnaireListModel.makeCollectionRef()
            )
            .subscribe { [unowned self] result in
                switch result {
                case .success(let list):
                    self.questionnaireList.accept(list)
                case .error(let error):
                    debugPrint(error)
                }
                self.tableView.refreshControl!.endRefreshing()
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
        let communityName = data.communityName
        let description = data.description ?? ""
        cell.configuration(
            // FIXME: 画像をFirebase Storageから取得するようにする
            iconImage: Asset.sample.image,
            title: title,
            communityName: communityName,
            description: description)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Main.TableView.cellHeight
    }
}
