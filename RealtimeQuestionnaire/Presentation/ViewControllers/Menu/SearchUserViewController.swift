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
    
    private let viewModel = SearchUserViewModel()
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
    }
    
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: SearchUserTableViewCell.self)
    }
    
    func bind() {
        viewModel.checkList
            .subscribe(onNext: { [unowned self] list in
                guard let cells = self.tableView.visibleCells as? [SearchUserTableViewCell] else { return }
                let checkListIds = list.map { $0.id }
                cells.forEach { cell in
                    checkListIds.contains(cell.id ?? "") ? cell.checked(true) : cell.checked(false)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension SearchUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.userList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SearchUserTableViewCell.self)
        let user = viewModel.userList.value[indexPath.row]
        cell.configure(
            id: user.id,
            nickname: user.nickname ?? "",
            iconImage: Asset.picture.image // FIXME: Firebase Storageから取得する
        )
        bind(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func bind(cell: SearchUserTableViewCell, indexPath: IndexPath) {
        cell.rx.checkTapped
            .map { [unowned self] _ in
                (self.viewModel.userList.value[indexPath.row].id, indexPath.row)
            }
            .drive(viewModel.checkedUserInfo)
            .disposed(by: disposeBag)
    }
}
