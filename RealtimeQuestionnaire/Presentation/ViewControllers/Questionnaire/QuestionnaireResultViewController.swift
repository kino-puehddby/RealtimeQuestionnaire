//
//  QuestionnaireResultViewController.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/04.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Charts

final class QuestionnaireResultViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var communityIconImageView: UIImageView!
    @IBOutlet weak private var communityNameLabel: UILabel!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var votesCountLabel: UILabel!
    @IBOutlet weak private var remainingTimeLabel: UILabel! // TODO: 回答締め切り機能
    @IBOutlet weak fileprivate var pieChartView: PieChartView!
    
    lazy var data: (communityName: String, communityIconImage: UIImage, questionnaire: QuestionnaireModel.Fields) = { preconditionFailure() }()
    
    private lazy var viewModel: QuestionnaireResultViewModel = { preconditionFailure() }()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        bind()
    }
    
    func setup() {
        viewModel = QuestionnaireResultViewModel(data: data)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellType: QuestionnaireResultTableViewCell.self)
        
        communityIconImageView.image = data.communityIconImage
        communityNameLabel.text = data.communityName
        titleLabel.text = data.questionnaire.title
    }
    
    func bind() {
        viewModel.percentValues
            .subscribe(onNext: { [unowned self] values in
                var pieChartEntries: [PieChartDataEntry] = []
                for (index, value) in values.enumerated() {
                    let entry: PieChartDataEntry = {
                        if value == 0 {
                            return PieChartDataEntry(value: value, label: "その他")
                        } else {
                            return PieChartDataEntry(value: value, label: self.data.questionnaire.choices[index])
                        }
                    }()
                    pieChartEntries.append(entry)
                }
                self.refreshPieChartView(dataList: pieChartEntries)
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.votesCount
            .map { $0.description }
            .bind(to: votesCountLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func refreshPieChartView(dataList: [PieChartDataEntry]) {
        let pieSet = PieChartDataSet(values: dataList, label: nil)
        pieSet.colors = ChartColorTemplates.vordiplom()
        let pieChartData = PieChartData(dataSet: pieSet)
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        formatter.multiplier = 1
        formatter.percentSymbol = " %"
        pieChartData.setValueFormatter(DefaultValueFormatter(formatter: formatter))
        pieChartData.setValueFont(.systemFont(ofSize: 12, weight: .regular))
        pieChartData.setValueTextColor(.black)
        
        pieChartView.data = pieChartData
        pieChartView.legend.enabled = false // 注釈を非表示
        pieChartView.drawHoleEnabled = false
        pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
}

extension QuestionnaireResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.percentValues.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: QuestionnaireResultTableViewCell.self)
        cell.configure(
            color: ChartColorTemplates.vordiplom()[indexPath.row],
            choice: data.questionnaire.choices[indexPath.row],
            percent: viewModel.percentValues.value[indexPath.row]
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return QuestionnaireDetail.QuestionnaireResult.cellHeight
    }
}
