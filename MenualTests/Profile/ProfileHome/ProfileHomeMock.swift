//
//  ProfileHomeMock.swift
//  MenualTests
//
//  Created by 정진균 on 2022/04/02.
//

import Foundation
import RIBs
import RxSwift
@testable import Menual

final class ProfileHomeBuildableMock: ProfileHomeBuildable {
    
    var buildHandler: ((_ listener: ProfileHomeListener) -> ProfileHomeRouting)?
    var buildCallCount: Int = 0
    func build(withListener listener: ProfileHomeListener) -> ProfileHomeRouting {
        buildCallCount += 1
        
        if let buildHandler = buildHandler {
            return buildHandler(listener)
        }
        
        fatalError()
    }
}

final class ProfileHomeRoutingMock: ProfileHomeRouting {
    var viewControllable: ViewControllable
    
    var interactableSetCallCount: Int = 0
    var interactable: Interactable {
        didSet {
            interactableSetCallCount += 1
        }
    }
    
    var childrenSetCallCount = 0
    var children: [Routing] = [Routing]() {
        didSet {
            childrenSetCallCount += 1
        }
    }
    
    var loadCallCount: Int = 0
    func load() {
        loadCallCount += 1
    }
    
    var attachChildCallCount: Int = 0
    func attachChild(_ child: Routing) {
        attachChildCallCount += 1
    }
    
    var detachChildCallCount: Int = 0
    func detachChild(_ child: Routing) {
        detachChildCallCount += 1
    }
    
    var lifecycleSubjectSetCallCount: Int = 0
    var lifecycleSubject = PublishSubject<RouterLifecycle>() {
      didSet {
        lifecycleSubjectSetCallCount += 1
      }
    }
    
    var lifecycle: Observable<RouterLifecycle> {
        return self.lifecycleSubject.asObservable()
    }
    
    init(
        interactable: Interactable,
        viewControllable: ViewControllable
    ) {
        self.interactable = interactable
        self.viewControllable = viewControllable
        
    }
}
