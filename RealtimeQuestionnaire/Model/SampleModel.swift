//
//  SampleModel.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/02/21.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

struct Model: Codable {
    enum MyEnum: Int, Codable {
        case one, two, three
    }
    
    let stringExample: String
    let booleanExample: Bool
    let numberExample: Double
    let dateExample: Date
    let arrayExample: [String]
    let optionalExample: Int?
    let objectExample: [String: String]
    let myEnumExample: MyEnum
}
