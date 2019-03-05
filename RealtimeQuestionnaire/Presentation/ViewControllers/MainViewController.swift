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
import SnapKit

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        deselectTableView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.showQuestionnaireDetail.rawValue {
            let vc = segue.destination as! QuestionnaireDetailContainerViewController
            if let data = viewModel.selectedCellData.value,
                let user = viewModel.user.value {
                vc.data = data
                vc.user = user
            }
        }
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
//                self.perform(segue: StoryboardSegue.Main.showUnansweredQuestionnaireList)
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        Observable
            .combineLatest(
                viewModel.questionnaireList,
                viewModel.user,
                viewModel.communityNames,
                viewModel.communityIconImages
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // FIXME: おかしい
        let headerView = MainHeaderView.loadFromNib()
        guard let user = viewModel.user.value,
            let name = user.communities[section]["name"] else { return nil }
        if user.communities.indices.contains(section) && viewModel.communityIconImages.value.indices.contains(section) {
            headerView.setup(image: viewModel.communityIconImages.value[section], text: name)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return Main.TableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.questionnaireList.value[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MainTableViewCell.self)
        let data = viewModel.questionnaireList.value[indexPath.section][indexPath.row]
        let title = data.title
        cell.configuration(title: title)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Main.TableView.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = viewModel.questionnaireList.value[indexPath.section][indexPath.row]
        viewModel.selectedCellData.accept(data)
        perform(segue: StoryboardSegue.Main.showQuestionnaireDetail)
    }
    
    func deselectTableView() {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
}

extension MainViewController {
    func pushCreateCommunity() {
        guard let navi = navigationController else { return }
        let createCommunityVC = StoryboardScene.CreateCommunity.initialScene.instantiate()
        navi.setViewControllers([self, createCommunityVC], animated: true)
    }
}
