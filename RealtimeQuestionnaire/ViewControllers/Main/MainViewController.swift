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
    
    private let disposeBag = DisposeBag()
    
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
        
        // API呼び出し
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
    
    func bind() {
        leftBarButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.slideMenuController()?.openLeft()
            })
            .disposed(by: disposeBag)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionnaireList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MainTableViewCell.self)
        // FIXME: Firestoreから取得したアンケート情報を入れる
        let data = questionnaireList.value[indexPath.row]
        let name = data.title
        let description = data.description ?? ""
        cell.configuration(
            iconImage: Asset.sample.image,
            name: name,
            description: description)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Main.TableView.cellHeight
    }
}
