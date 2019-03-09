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
    
    private let disposeBag = DisposeBag()
    
    lazy var photoLibraryManager: PhotoLibraryManager = { preconditionFailure() }()
    let viewModel = ChangeMemberInfoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.ChangeMemberInfo.showSearchCommunity.rawValue {
            guard let vc = segue.destination as? SearchCommunityViewController else { return }
            vc.belongingList = viewModel.belongingList.value
        }
    }
    
    private func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: ChangeMemberInfoTableViewCell.self)
        
        photoLibraryManager = PhotoLibraryManager(parentViewController: self)
    }
    
    private func bind() {
        changeImageButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.photoLibraryManager.callPhotoLibrary()
            })
            .disposed(by: disposeBag)
        
        nicknameTextField.rx.text
            .bind(to: viewModel.nickname)
            .disposed(by: disposeBag)
        
        searchCommunityButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.perform(segue: StoryboardSegue.ChangeMemberInfo.showSearchCommunity)
            })
            .disposed(by: disposeBag)
        
        changeButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.viewModel.updateMemberInfo()
            })
            .disposed(by: disposeBag)
        
        viewModel.iconImage
            .subscribe(onNext: { [unowned self] image in
                if let image = image {
                    self.changeImageButton.setImage(image, for: .normal)
                } else {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    self.changeImageButton.setImage(appDelegate.photoLibraryImage, for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.belongingList
            .subscribe(onNext: { [unowned self] _ in
                self.tableView.reloadData()
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
                    self.viewModel.uploadFirebaseStorage()
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
        return viewModel.belongingList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ChangeMemberInfoTableViewCell.self)
        cell.configure(
            image: Asset.picture.image, // FIXME: サンプル
            communityName: viewModel.belongingList.value[indexPath.row].name,
            id: viewModel.belongingList.value[indexPath.row].id
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CreateCommunity.TableView.cellHeight
    }
}

extension ChangeMemberInfoViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.photoLibraryImage = pickedImage
            changeImageButton.setImage(pickedImage, for: .normal)
        }
        
        let trimImageVC = StoryboardScene.TrimImage.trimImageViewController.instantiate()
        trimImageVC.postDissmissionAction = { picker.dismiss(animated: true) } // コールバックを受け取る
        picker.present(trimImageVC, animated: true)
    }
}
