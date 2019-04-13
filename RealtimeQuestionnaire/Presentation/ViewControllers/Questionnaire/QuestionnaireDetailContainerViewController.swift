//
//  QuestionnaireDetailViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/04.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

final class QuestionnaireDetailContainerViewController: UIViewController {
    
    @IBOutlet weak private var navigationBarItem: UINavigationItem!
    
    lazy var data: (communityName: String, communityIconImage: UIImage, questionnaire: QuestionnaireModel.Fields) = { preconditionFailure() }()
    lazy var user: UserModel.Fields = { preconditionFailure() }()
    
    private lazy var viewModel: QuestionnaireDetailViewModel = { preconditionFailure() }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bindViewModel()
    }
    
    private func setup() {
        viewModel = QuestionnaireDetailViewModel(
            data: data,
            user: user
        )
    }
    
    private func bindViewModel() {
        viewModel.mode
            .subscribe(onNext: { [unowned self] mode in
                self.switchDisplay(mode: mode)
            })
            .disposed(by: disposeBag)
    }
    
    private func switchDisplay(mode: QuestionnaireDetailViewModel.QuestionnaireDetailMode) {
        switch mode {
        case .answer:
            navigationBarItem.title = L10n.Questionnaire.Detail.answer
            let vc = StoryboardScene.QuestionnaireDetail.answerQuestionnaireViewController.instantiate()
            vc.data = data
            addChildVC(vc)
        case .result:
            self.navigationBarItem.title = L10n.Questionnaire.Detail.result
            let vc = StoryboardScene.QuestionnaireDetail.questionnaireResultViewController.instantiate()
            vc.data = data
            addChildVC(vc)
        }
    }
}
