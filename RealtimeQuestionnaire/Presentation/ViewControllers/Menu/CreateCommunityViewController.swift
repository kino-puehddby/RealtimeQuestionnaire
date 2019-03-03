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
import FirebaseStorage

final class CreateCommunityViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var changeImageButton: UIButton!
    @IBOutlet weak private var communityNameLabel: UITextField!
    @IBOutlet weak private var communityNameInvalidLabel: UILabel!
    @IBOutlet weak private var inviteButton: UIButton!
    @IBOutlet weak private var createButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private let viewModel = CreateCommunityViewModel()
    
    lazy var photoLibraryManager: PhotoLibraryManager = { preconditionFailure() }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        changeImageButton.setImage(appDelegate.photoLibraryImage, for: .normal)
    }
    
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: CreateCommunityTableViewCell.self)
        
        photoLibraryManager = PhotoLibraryManager(parentViewController: self)
    }
    
    func bind() {
        changeImageButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.photoLibraryManager.callPhotoLibrary()
            })
            .disposed(by: disposeBag)
        
        createButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.viewModel.generateCommunityId()
            })
            .disposed(by: disposeBag)
        
        inviteButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.perform(segue: StoryboardSegue.CreateCommunity.showSearchUser)
            })
            .disposed(by: disposeBag)
        
        communityNameLabel.rx.text.orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.communityName)
            .disposed(by: disposeBag)
        
        viewModel.postCompleted
            .subscribe(onNext: { [unowned self] status in
                switch status {
                case .success:
                    guard let image = self.changeImageButton.imageView?.image else { return }
                    self.uploadFirebaseStorage(image: image)
                case .error(let error):
                    debugPrint(error)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.userUpdated
            .subscribe(onNext: { [unowned self] status in
                switch status {
                case .success:
                    guard let navi = self.navigationController else { return }
                    navi.popViewController(animated: true)
                case .error(let error):
                    debugPrint(error)
                }
            })
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
            .subscribe(onNext: { [unowned self] isValid in
                self.createButton.backgroundColor = isValid ? Asset.systemBlue.color : .lightGray
            })
            .disposed(by: disposeBag)
    }
    
    func uploadFirebaseStorage(image: UIImage) {
        // 保存したイメージをFirebaseStorageに保存する
        let storageRef = Storage.storage().reference()
        
        if let data = image.pngData() {
            let reference = storageRef.child("images/" + viewModel.communityName.value + ".jpg")
            reference.putData(data)
        }
    }
}

extension CreateCommunityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CreateCommunityTableViewCell.self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CreateCommunity.TableView.cellHeight
    }
}

extension CreateCommunityViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.photoLibraryImage = pickedImage
        }
        
        let trimImageVC = StoryboardScene.TrimImage.trimImageViewController.instantiate()
        trimImageVC.postDissmissionAction = { picker.dismiss(animated: true) } // コールバックを受け取る
        picker.present(trimImageVC, animated: true)
    }
}
