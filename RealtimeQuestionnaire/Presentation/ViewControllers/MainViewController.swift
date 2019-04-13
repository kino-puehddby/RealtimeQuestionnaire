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
    @IBOutlet weak private var tableView: UITableView!
    
    @IBOutlet weak private var createQuestionnaireButton: UIButton!
    @IBOutlet weak private var answerQuestionnaireButton: UIButton!
    
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setup()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        deselectTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // TODO: Menuのアイコン画像の更新タイミングがおかしいのでどうにかする
        guard let menuVC = slideMenuController()?.leftViewController as? MenuViewController else { return }
        menuVC.viewModel.downloadIconImage()
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
    
    private func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: MainTableViewCell.self)
    }
    
    private func bind() {
        leftBarButton.rx.tap.asSignal()
            .emit(onNext: { [unowned self] in
                self.slideMenuController()?.openLeft()
            })
            .disposed(by: disposeBag)
        
        createQuestionnaireButton.rx.tap.asSignal()
            .emit(onNext: { [unowned self] in
                self.perform(segue: StoryboardSegue.Main.showCreateQuestionnaire)
            })
            .disposed(by: disposeBag)
        
        answerQuestionnaireButton.rx.tap.asSignal()
            .emit(onNext: { [unowned self] in
                self.perform(segue: StoryboardSegue.Main.showUnansweredQuestionnaireList)
            })
            .disposed(by: disposeBag)
        
        viewModel.summary
            .subscribe(onNext: { [unowned self] _ in
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.summary.value.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = MainHeaderView.loadFromNib()
        if viewModel.summary.value.indices.contains(section) {
            let image = viewModel.summary.value[section].image
            let name = viewModel.summary.value[section].name
            headerView.configure(name: name, image: image)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Main.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.summary.value[section].questionnaires.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MainTableViewCell.self)
        let data = viewModel.summary.value[indexPath.section].questionnaires[indexPath.row]
        let title = data.title
        let answered = viewModel.answered(id: data.id)
        cell.configuration(title: title, answered: answered)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Main.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = (
            communityName: viewModel.summary.value[indexPath.section].name,
            communityIconImage: viewModel.summary.value[indexPath.section].image,
            questionnaire: viewModel.summary.value[indexPath.section].questionnaires[indexPath.row]
        )
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
