//
//  File.swift
//  Menual
//
//  Created by 정진균 on 2021/12/11.
//

import Foundation
import RIBs
import RxRelay

final class AppComponent: Component<EmptyDependency>, AppRootDependency {
    
    var diaryUUIDRelay: BehaviorRelay<String>
  
    init(
        diaryUUIDRelay: BehaviorRelay<String>
    ) {
        self.diaryUUIDRelay = diaryUUIDRelay
        super.init(dependency: EmptyComponent())
  }
  
}
