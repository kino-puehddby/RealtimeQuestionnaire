//
//  SearchCommunityViewController.swift
//  RealtimeQuestionnaire
//
//  Created by HisayaSugita on 2019/03/09.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchCommunityViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet weak private var decideButton: UIButton!
    @IBOutlet weak private var filterTextField: UITextField!
    
    private let viewModel = SearchCommunityViewModel()
    
    var belongingList: [CommunityModel.Fields]!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
    }
    
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: SearchCommunityTableViewCell.self)
    }
    
    func bind() {
        decideButton.rx.tap
            .map { [unowned self] in
                let cells = self.tableView.visibleCells as! [SearchCommunityTableViewCell]
                let isCheckedLIst = cells.map { $0.isChecked }
                let isFilttered = !(self.filterTextField.text == nil || self.filterTextField.text == "")
                return (isCheckedLIst, isFilttered)
            }
            .bind(to: viewModel.decideAction)
            .disposed(by: disposeBag)
        
        filterTextField.rx.text
            .bind(to: viewModel.filterTrigger)
            .disposed(by: disposeBag)
        
        viewModel.checkList
            .skip(1)
            .subscribe(onNext: { [unowned self] _ in
                self.pop()
            })
            .disposed(by: disposeBag)
        
        viewModel.filteredCommunityList
            .subscribe(onNext: { [unowned self] _ in
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    func pop() {
        guard let navi = navigationController,
            let changeMemberInfoVC = navi.viewControllers[navi.viewControllers.count - 2] as? ChangeMemberInfoViewController else { return }
        changeMemberInfoVC.viewModel.belongingList.accept(viewModel.checkList.value)
        navi.popViewController(animated: true)
    }
}

extension SearchCommunityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterTextField.text == nil || filterTextField.text == "" {
            return viewModel.communityList.value.count
        }
        return viewModel.filteredCommunityList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SearchCommunityTableViewCell.self)
        let community: CommunityModel.Fields = {
            if filterTextField.text == nil || filterTextField.text == "" {
                return viewModel.communityList.value[indexPath.row]
            } else {
                return viewModel.filteredCommunityList.value[indexPath.row]
            }
        }()
        cell.configure(
            id: community.id,
            name: community.name,
            iconImage: Asset.picture.image // FIXME: 画像をFirebase Storageから取得する
        )
        let ids = belongingList.map { $0.id }
        if ids.contains(community.id) {
            cell.checked(true)
        } else {
            cell.checked(false)
        }
        bind(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func bind(cell: SearchCommunityTableViewCell, indexPath: IndexPath) {
//        cell.rx.checkTapped
//            .map { [unowned self] _ in
//                if self.filterTextField.text == nil || self.filterTextField.text == "" {
//                    return (self.viewModel.communityList.value[indexPath.row].id, indexPath.row)
//                } else {
//                    return (self.viewModel.filteredCommunityList.value[indexPath.row].id, indexPath.row)
//                }
//            }
//            .drive(viewModel.checkedCommunityInfo)
//            .disposed(by: disposeBag)
    }
}
