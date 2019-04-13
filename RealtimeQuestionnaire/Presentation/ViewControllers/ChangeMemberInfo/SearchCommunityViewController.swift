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
    
    private lazy var viewModel: SearchCommunityViewModel = { preconditionFailure() }()
    
    lazy var belongingCommunityInfos: [(id: String, name: String, image: UIImage)] = { preconditionFailure() }()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
    }
    
    private func setup() {
        viewModel = SearchCommunityViewModel(infos: belongingCommunityInfos)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: SearchCommunityTableViewCell.self)
    }
    
    private func bind() {
        decideButton.rx.tap.asSignal()
            .map { [unowned self] in
                let cells = self.tableView.visibleCells as! [SearchCommunityTableViewCell]
                let isCheckedLIst = cells.map { $0.isChecked }
                let isFilttered = !(self.filterTextField.text == nil || self.filterTextField.text == "")
                return (isCheckedLIst, isFilttered)
            }
            .emit(to: viewModel.decideAction)
            .disposed(by: disposeBag)
        
        filterTextField.rx.text
            .bind(to: viewModel.filterTrigger)
            .disposed(by: disposeBag)
        
        viewModel.communityInfos
            .skip(1)
            .subscribe(onNext: { [unowned self] _ in
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.belongingCommunityInfos
            .skip(2)
            .subscribe(onNext: { [unowned self] _ in
                self.pop()
            })
            .disposed(by: disposeBag)
    }
    
    private func pop() {
        guard let navi = navigationController,
            let changeMemberInfoVC = navi.viewControllers[navi.viewControllers.count - 2] as? ChangeMemberInfoViewController else { return }
        changeMemberInfoVC.viewModel.belongingCommunityInfos.accept(viewModel.belongingCommunityInfos.value)
        navi.popViewController(animated: true)
    }
}

extension SearchCommunityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filterTextField.text == nil || filterTextField.text == "" {
            return viewModel.communityInfos.value.count
        }
        return viewModel.filteredCommunityInfos.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SearchCommunityTableViewCell.self)
        let community: (id: String, name: String, image: UIImage) = {
            if filterTextField.text == nil || filterTextField.text == "" {
                return viewModel.communityInfos.value[indexPath.row]
            } else {
                return viewModel.filteredCommunityInfos.value[indexPath.row]
            }
        }()
        cell.configure(
            id: community.id,
            name: community.name,
            iconImage: community.image
        )
        let ids = belongingCommunityInfos.map { $0.id }
        if ids.contains(community.id) {
            cell.checked(true)
        } else {
            cell.checked(false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchCommunity.cellHeight
    }
}
