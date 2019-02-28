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
import FirebaseFirestore

final class MainViewController: UIViewController {

    @IBOutlet weak private var leftBarButton: UIBarButtonItem!
    @IBOutlet weak private var rightBarButton: UIBarButtonItem!
    @IBOutlet weak private var tableView: UITableView!
    
    @IBOutlet weak private var createQuestionnaireButton: UIButton!
    @IBOutlet weak private var answerQuestionnaireButton: UIButton!
    
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: ViewModelで必要なデータの管理をするようにする
        
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
        
        Observable
            .combineLatest(
                viewModel.questionnaireList,
                viewModel.user,
                viewModel.communityNames
            )
            .subscribe(onNext: { [unowned self] _ in
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.questionnaireList.value.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let user = viewModel.user.value,
            let name = user.communities[section][UsersCommunity.name.rawValue] else {
            return nil
        }
        return name
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.questionnaireList.value[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MainTableViewCell.self)
        let data = viewModel.questionnaireList.value[indexPath.section][indexPath.row]
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
