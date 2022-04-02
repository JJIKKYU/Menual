//
//  DiarySearchMock.swift
//  MenualTests
//
//  Created by 정진균 on 2022/04/02.
//

import Foundation
import RIBs
import RxSwift
@testable import Menual

final class DiarySearchBuildableMock: DiarySearchBuildable {
    
    var buildHandler: ((_ listener: DiarySearchListener) -> DiarySearchRouting)?
    var buildCallCount: Int = 0
    func build(withListener listener: DiarySearchListener) -> DiarySearchRouting {
        buildCallCount += 1
        
        if let buildHandler = buildHandler {
            return buildHandler(listener)
        }
        
        fatalError()
    }
}

final class DiarySearchRoutingMock: DiarySearchRouting {
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

final class DiarySearchInteractableMock: DiarySearchInteractable {
    
    var router: DiarySearchRouting?
    var listener: DiarySearchListener?
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

final class DiarySearchViewControllerMock: DiarySearchPresentable, DiarySearchViewControllable {
    var listener: DiarySearchPresentableListener?
    var uiviewControllerSetCallCount: Int = 0
    var uiviewController: UIViewController = UIViewController() {
        didSet {
            uiviewControllerSetCallCount += 1
            
        }
    }
    
    init() {
        
    }
}


final class DiarySearchPresentableMock: DiarySearchPresentable {
    var listener: DiarySearchPresentableListener?
    
    init() {
        
    }
}

final class DiarySearchDependencyMock: DiarySearchDependency {
    
}

final class DiarySearchListenerMock: DiarySearchListener {
    var diarySearchPressedBackBtnCallCount: Int = 0
    func diarySearchPressedBackBtn() {
        diarySearchPressedBackBtnCallCount += 1
    }
}
