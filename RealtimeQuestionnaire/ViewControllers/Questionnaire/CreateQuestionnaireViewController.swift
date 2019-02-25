//
//  CreateQuestionnaireViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/20.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

final class CreateQuestionnaireViewController: UIViewController {

    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var titleField: UITextField!
    @IBOutlet weak private var communityPickerField: UITextField!
    @IBOutlet weak private var descriptionField: UITextView!
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        titleField.resignFirstResponder()
        communityPickerField.resignFirstResponder()
        descriptionField.resignFirstResponder()
    }
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    func setup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: ChoiceTableViewCell.self)
        
        setupKeyboardUpDownWithTextField()
    }
}

extension CreateQuestionnaireViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ChoiceTableViewCell.self)
        
        return cell
    }
}
