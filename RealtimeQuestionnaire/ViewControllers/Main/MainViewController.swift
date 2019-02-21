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

final class MainViewController: UIViewController {

    @IBOutlet weak private var leftBarButton: UIBarButtonItem!
    @IBOutlet weak private var rightBarButton: UIBarButtonItem!
    @IBOutlet weak private var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    let questionnaireList = BehaviorRelay<[QuestionnaireListModel]?>(value: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableViewに参加中のアンケート一覧を表示する
        
        setup()
        bind()
        
        let responses = APIs.getArray(
            modelType: QuestionnaireListModel.self,
            collectionKey: .questionnaireListGet
        )
        questionnaireList.accept(responses)
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
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionnaireList.value?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MainTableViewCell.self)
        // FIXME: Firestoreから取得したアンケート情報を入れる
        cell.configuration(iconImage: Asset.risu.image, name: L10n.Sample.Questionnaire.Community.name, description: L10n.Sample.Questionnaire.Community.title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Main.TableView.cellHeight
    }
}
