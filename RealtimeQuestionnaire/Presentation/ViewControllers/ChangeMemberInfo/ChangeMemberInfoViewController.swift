//
//  ChangeMemberInfoViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/01.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChangeMemberInfoViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var changeImageButton: UIButton!
    @IBOutlet weak private var nicknameTextField: UITextField!
    @IBOutlet weak private var searchCommunityButton: UIButton!
    @IBOutlet weak private var changeButton: UIButton!
    
    enum ChangeMemberInfoType {
        case register
        case update
    }
    
    private let disposeBag = DisposeBag()
    
    lazy var photoLibraryManager: PhotoLibraryManager = { preconditionFailure() }()
    lazy var viewModel: ChangeMemberInfoViewModel = { preconditionFailure() }()
    lazy var type: ChangeMemberInfoType = { preconditionFailure() }()
    
    lazy var belongingCommunityInfos: [(id: String, name: String, image: UIImage)] = { preconditionFailure() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bindViews()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.ChangeMemberInfo.showSearchCommunity.rawValue {
            guard let vc = segue.destination as? SearchCommunityViewController else { return }
            vc.belongingCommunityInfos = viewModel.belongingCommunityInfos.value
        }
    }
    
    private func setup() {
        viewModel = ChangeMemberInfoViewModel(belongingCommunityInfos: belongingCommunityInfos)
        photoLibraryManager = PhotoLibraryManager(parentViewController: self)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: ChangeMemberInfoTableViewCell.self)
        
        switch type {
        case .register:
            changeButton.setTitle(L10n.Menu.ChangeMemberInfo.ButtonTItle.register, for: .normal)
        case .update:
            changeButton.setTitle(L10n.Menu.ChangeMemberInfo.ButtonTItle.update, for: .normal)
        }
    }
    
    private func bindViews() {
        changeImageButton.rx.tap.asSignal()
            .emit(onNext: { [unowned self] in
                self.photoLibraryManager.callPhotoLibrary()
            })
            .disposed(by: disposeBag)
        
        nicknameTextField.rx.text
            .bind(to: viewModel.nickname)
            .disposed(by: disposeBag)
        
        searchCommunityButton.rx.tap.asSignal()
            .emit(onNext: { [unowned self] in
                switch self.type {
                case .register:
                    self.switchMainViewController()
                case .update:
                    self.perform(segue: StoryboardSegue.ChangeMemberInfo.showSearchCommunity)
                }
            })
            .disposed(by: disposeBag)
        
        changeButton.rx.tap.asSignal()
            .emit(onNext: { [unowned self] in
                self.viewModel.updateMemberInfo()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        viewModel.iconImage
            .skip(1)
            .map { $0 != nil ? $0 : Asset.picture.image }
            .subscribe(onNext: { [unowned self] image in
                self.changeImageButton.setImage(image, for: .normal)
            })
            .disposed(by: disposeBag)
        
        viewModel.nickname
            .bind(to: nicknameTextField.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.completed
            .subscribe(onNext: { [unowned self] event in
                switch event {
                case .success:
                    guard let navi = self.navigationController else { return }
                    navi.popViewController(animated: true)
                case .error(let error):
                    debugPrint(error)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension ChangeMemberInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.belongingCommunityInfos.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ChangeMemberInfoTableViewCell.self)
        cell.configure(
            image: viewModel.belongingCommunityInfos.value[indexPath.row].image,
            communityName: viewModel.belongingCommunityInfos.value[indexPath.row].name,
            id: viewModel.belongingCommunityInfos.value[indexPath.row].id
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ChangeMemberInfo.cellHeight
    }
}

extension ChangeMemberInfoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.photoLibraryImage = pickedImage
            changeImageButton.setImage(pickedImage, for: .normal)
            viewModel.iconImage.accept(pickedImage)
        }
        picker.dismiss(animated: true)
    }
}
