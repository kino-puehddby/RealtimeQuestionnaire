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
    
    @IBOutlet weak var communityIconImageView: UIImageView!
    @IBOutlet weak var communityNameLabel: UILabel!
    @IBOutlet weak fileprivate var pieChartView: PieChartView!
    
    lazy var data: QuestionnaireModel.Fields = { preconditionFailure() }()
    
    // サンプル
    let pieChartEntries = [
        PieChartDataEntry(value: 1, label: "A"),
        PieChartDataEntry(value: 20, label: "B"),
        PieChartDataEntry(value: 30, label: "C"),
        PieChartDataEntry(value: 40, label: "D"),
        PieChartDataEntry(value: 50, label: "E")
    ]
    
    private lazy var viewModel: QuestionnaireResultViewModel = { preconditionFailure() }()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupPieChartView()
    }
    
    func setup() {
        viewModel = QuestionnaireResultViewModel(questionnaireData: data)
    }
}

extension QuestionnaireResultViewController: ChartViewDelegate {
    func setupPieChartView() {
        let pieSet = PieChartDataSet(values: pieChartEntries, label: "Data")
        pieSet.colors = ChartColorTemplates.vordiplom()
        pieChartView.data = PieChartData(dataSet: pieSet)
        pieChartView.drawHoleEnabled = false
        pieChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
}
