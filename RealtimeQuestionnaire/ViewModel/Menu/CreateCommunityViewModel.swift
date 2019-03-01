//
//  CreateCommunityViewModel.swift
//  RealtimeQuestionnaire
//
//  Created by 杉田 尚哉 on 2019/03/01.
//  Copyright © 2019 hisayasugita. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

final class CreateCommunityViewModel {
    
    let communityName = BehaviorRelay<String>(value: "")
    
    private let disposeBag = DisposeBag()
    
    init() {
        
    }
}
