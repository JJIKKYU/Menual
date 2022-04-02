//
//  DiaryHomeMock.swift
//  MenualTests
//
//  Created by 정진균 on 2022/04/02.
//

import Foundation
import RxSwift
import RIBs
@testable import Menual

final class DiaryHomePresentableMock: DiaryHomePresentable {
    var listener: DiaryHomePresentableListener?
    
    // 구현해줘야하는 메소드도 fix 하면 바로 불러올 수 있음
    // 해당 메소드가 불렸는지, 몇 번 불렸는지 count 하거나 실제 값을 검증할 수 있음.
    
    init() {
        
    }
}

final class DiaryHomeDependencyMock: DiaryHomeDependency {
    // repository가 따로 없으니까 일단 비어있는 상태로
}

final class DiaryHomeInteractableMock: DiaryHomeInteractable {
    
    var router: DiaryHomeRouting?
    var listener: DiaryHomeListener?
    var isActive: Bool {
        isActiveSubject.value
    }
    var isActiveStream: Observable<Bool> { isActiveSubject.asObservable() }
    private let isActiveSubject = Variable<Bool>(false)
    
    var presentationDelegateProxy = AdaptivePresentationControllerDelegateProxy()
    
    func activate() {
    }
    
    func deactivate() {
    }
    
    var profileHomePressedBackBtnCallCount: Int = 0
    func profileHomePressedBackBtn() {
        profileHomePressedBackBtnCallCount += 1
    }
    
    var diarySearchPressedBackBtnCallCount: Int = 0
    func diarySearchPressedBackBtn() {
        diarySearchPressedBackBtnCallCount += 1
    }
}

final class DiaryHomeRoutingMock: DiaryHomeRouting {
    
    // Variables
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
    
    var attachMyPageCallCount: Int = 0
    func attachMyPage() {
        attachMyPageCallCount += 1
    }
    
    var detachMyPageCallCount: Int = 0
    func detachMyPage() {
        detachMyPageCallCount += 1
    }
    
    var attachDiarySearchCallCount: Int = 0
    func attachDiarySearch() {
        attachDiarySearchCallCount += 1
    }
    
    var dettachDiarySearchCallCount: Int = 0
    func detachDiarySearch() {
        dettachDiarySearchCallCount += 1
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
    
    
}

final class DiaryHomeBuildableMock: DiaryHomeBuildable {
    
    var buildCallCount: Int = 0
    func build(withListener listener: DiaryHomeListener) -> DiaryHomeRouting {
        buildCallCount += 1
        return DiaryHomeRoutingMock(interactable: Interactor(),
                                    viewControllable: ViewControllableMock())
    }
    
    public init() {
        
    }
}

final class DiaryHomeViewControllableMock: DiaryHomePresentable, DiaryHomeViewControllable {
    var listener: DiaryHomePresentableListener?
    
    var uiviewControllerSetCallCount: Int = 0
    var uiviewController: UIViewController = UIViewController() {
        didSet {
            uiviewControllerSetCallCount += 1
            
        }
    }
    
    init() {
        
    }
    
}
