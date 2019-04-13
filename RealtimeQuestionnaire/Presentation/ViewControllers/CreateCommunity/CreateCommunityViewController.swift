//
//  CreateCommunityViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/28.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

final class CreateCommunityViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var changeImageButton: UIButton!
    @IBOutlet weak private var communityNameLabel: UITextField!
    @IBOutlet weak private var communityNameInvalidLabel: UILabel!
    @IBOutlet weak private var inviteButton: UIButton!
    @IBOutlet weak private var createButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private let viewModel = CreateCommunityViewModel()
    
    var checkList = BehaviorRelay<[UserModel.Fields]>(value: [])
    
    lazy var photoLibraryManager: PhotoLibraryManager = { preconditionFailure() }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bindViews()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        changeImageButton.setImage(appDelegate.photoLibraryImage, for: .normal)
    }
    
    private func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: CreateCommunityTableViewCell.self)
        
        photoLibraryManager = PhotoLibraryManager(parentViewController: self)
    }
    
    private func bindViews() {
        changeImageButton.rx.tap.asSignal()
            .emit(onNext: { [unowned self] in
                self.photoLibraryManager.callPhotoLibrary()
            })
            .disposed(by: disposeBag)
        
        createButton.rx.tap.asSignal()
            .emit(onNext: { [unowned self] in
                self.viewModel.generateCommunityId()
            })
            .disposed(by: disposeBag)
        
        inviteButton.rx.tap.asSignal()
            .emit(onNext: { [unowned self] in
                self.perform(segue: StoryboardSegue.CreateCommunity.showSearchUser)
            })
            .disposed(by: disposeBag)
        
        communityNameLabel.rx.text.orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.communityName)
            .disposed(by: disposeBag)
        
        let isValid = communityNameLabel.rx.text
            .map { $0 != nil && $0 != "" }
            .share(replay: 1)
        isValid
            .bind(to: createButton.rx.isEnabled)
            .disposed(by: disposeBag)
        isValid
            .bind(to: communityNameInvalidLabel.rx.isHidden)
            .disposed(by: disposeBag)
        isValid
            .map { $0 ? Asset.systemBlue.color : .lightGray }
            .bind(to: createButton.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        viewModel.completed
            .subscribe(onNext: { [unowned self] status in
                switch status {
                case .success:
                    guard let image = self.changeImageButton.imageView?.image,
                        let navi = self.navigationController else { return }
                    self.viewModel.uploadFirebaseStorage(image: image)
                    navi.popViewController(animated: true)
                case .error(let error):
                    debugPrint(error)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension CreateCommunityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CreateCommunityTableViewCell.self)
        cell.configure(
            image: Asset.picture.image, // FIXME: サンプル
            nickname: checkList.value[indexPath.row].nickname ?? "",
            id: checkList.value[indexPath.row].id
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CreateCommunity.cellHeight
    }
}

extension CreateCommunityViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.photoLibraryImage = pickedImage
        }
        
        picker.dismiss(animated: true)
    }
}
