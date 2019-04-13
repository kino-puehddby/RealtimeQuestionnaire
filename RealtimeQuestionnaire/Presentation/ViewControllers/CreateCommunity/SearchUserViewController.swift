//
//  SearchUserViewController.swift
//  RealtimeQuestionnaire
//
//  Created by HisayaSugita on 2019/03/03.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

final class SearchUserViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var decideButton: UIButton!
    @IBOutlet weak private var filterTextField: UITextField!
    
    private let viewModel = SearchUserViewModel()
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
    }
    
    private func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: SearchUserTableViewCell.self)
    }
    
    private func bind() {
        decideButton.rx.tap.asSignal()
            .emit(onNext: { [unowned self] in
                self.pop()
            })
            .disposed(by: disposeBag)
        
        filterTextField.rx.text
            .bind(to: viewModel.filterTrigger)
            .disposed(by: disposeBag)
        
        viewModel.checkList
            .subscribe(onNext: { [unowned self] list in
                guard let cells = self.tableView.visibleCells as? [SearchUserTableViewCell] else { return }
                let checkListIds = list.map { $0.id }
                cells.forEach { cell in
                    checkListIds.contains(cell.id ?? "") ? cell.checked(true) : cell.checked(false)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.filteredUserList
            .subscribe(onNext: { [unowned self] _ in
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func pop() {
        guard let navi = navigationController,
            let createCommunityVC = navi.viewControllers[navi.viewControllers.count - 2] as? CreateCommunityViewController else { return }
        createCommunityVC.checkList.accept(viewModel.checkList.value)
        navi.popViewController(animated: true)
    }
}

extension SearchUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterTextField.text == nil || filterTextField.text == "" {
            return viewModel.userList.value.count
        }
        return viewModel.filteredUserList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SearchUserTableViewCell.self)
        let user: UserModel.Fields = {
            if filterTextField.text == nil || filterTextField.text == "" {
                return viewModel.userList.value[indexPath.row]
            } else {
                return viewModel.filteredUserList.value[indexPath.row]
            }
        }()
        cell.configure(
            id: user.id,
            nickname: user.nickname ?? "",
            iconImage: Asset.picture.image // FIXME: 画像をFirebase Storageから取得する
        )
        bind(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchUser.cellHeight
    }
    
    func bind(cell: SearchUserTableViewCell, indexPath: IndexPath) {
        cell.rx.checkTapped
            .map { [unowned self] _ in
                if self.filterTextField.text == nil || self.filterTextField.text == "" {
                    return (self.viewModel.userList.value[indexPath.row].id, indexPath.row)
                } else {
                    return (self.viewModel.filteredUserList.value[indexPath.row].id, indexPath.row)
                }
            }
            .drive(viewModel.checkedUserInfo)
            .disposed(by: cell.disposeBag)
    }
}
