//
//  DiaryMomentsMock.swift
//  MenualTests
//
//  Created by 정진균 on 2022/04/03.
//

import Foundation
import RIBs
import RxSwift
@testable import Menual

final class DiaryMomentsBuildableMock: DiaryMomentsBuildable {
    var buildHandler: ((_ listener: DiaryMomentsListener) -> DiaryMomentsRouting)?
    var buildCallCount: Int = 0
    func build(withListener listener: DiaryMomentsListener) -> DiaryMomentsRouting {
        buildCallCount += 1

        if let buildHandler = buildHandler {
            return buildHandler(listener)
        }

        fatalError()
    }
}

final class DiaryMomentsRoutingMock: DiaryMomentsRouting {
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

final class DiaryMomentsInteractableMock: DiaryMomentsInteractable {
    var router: DiaryMomentsRouting?
    var listener: DiaryMomentsListener?
    var isActive: Bool {
        isActiveSubject.value
    }
    var isActiveStream: Observable<Bool> { isActiveSubject.asObservable() }
    private let isActiveSubject = Variable<Bool>(false)
    
    func activate() {
    }
    
    func deactivate() {
    }
}

final class DiaryMomentsViewControllerMock: DiaryMomentsViewControllable, DiaryMomentsPresentable {
    var listener: DiaryMomentsPresentableListener?
    
    var uiviewControllerSetCallCount: Int = 0
    var uiviewController: UIViewController = UIViewController() {
        didSet {
            uiviewControllerSetCallCount += 1
            
        }
    }
    
    var pressedBackBtnCallCount: Int = 0
    func pressedBackBtn() {
        pressedBackBtnCallCount += 1
    }
    
    init() {
        
    }
}

final class DiaryMomentsPresentableMock: DiaryMomentsPresentable {
    var pressedBackBtnCallCount: Int = 0
    func pressedBackBtn() {
        pressedBackBtnCallCount += 1
    }
    
    var listener: DiaryMomentsPresentableListener?
    
    init() {
        
    }
}

final class DiaryMomentsDependencyMock: DiaryMomentsDependency {
    
}

final class DiaryMomentsListenerMock: DiaryMomentsListener {
    var diaryMomentsPressedBackBtnCallCount: Int = 0
    func diaryMomentsPressedBackBtn() {
        diaryMomentsPressedBackBtnCallCount += 1
    }
}
