//
//  DiaryWritingMock.swift
//  
//
//  Created by 정진균 on 2023/02/11.
//

import Foundation
import DiaryWriting
import MenualEntity
import MenualRepository
import RIBs
import RxRelay
import RxSwift
import MenualRepositoryTestSupport

// MARK: - DiaryWritingPresentableMock
final class DiaryWritingPresentableMock: DiaryWritingPresentable {
    
    var listener: DiaryWriting.DiaryWritingPresentableListener?
    
    var setUICallCount = 0
    func setUI(writeType: DiaryWriting.WritingType) {
        setUICallCount += 1
    }
    
    var setWeatherViewCallCount = 0
    func setWeatherView(model: MenualEntity.WeatherModelRealm) {
        setWeatherViewCallCount += 1
    }
    
    var setPlaceViewCallCount = 0
    func setPlaceView(model: MenualEntity.PlaceModelRealm) {
        setPlaceViewCallCount += 1
    }
    
    var setDiaryEditModeCallCount = 0
    func setDiaryEditMode(diaryModel: MenualEntity.DiaryModelRealm) {
        setDiaryEditModeCallCount += 1
    }
    
    var setTempSaveModelCallCount = 0
    func setTempSaveModel(tempSaveModel: MenualEntity.TempSaveModelRealm) {
        setTempSaveModelCallCount += 1
    }
    
    var resetDiaryCallCount = 0
    func resetDiary() {
        resetDiaryCallCount += 1
    }
}

// MARK: - DiaryWritingDependencyMock
final class DiaryWritingDependencyMock: DiaryWritingInteractorDependency {
    var diaryRepository: DiaryRepository = DiaryRepositoryMock()
    
    init() { }
}

// MARK: - DiaryWritingListenerMock
final class DiaryWritingListenerMock: DiaryWritingListener {
    var diaryWritingPressedBackBtnCallCount = 0
    func diaryWritingPressedBackBtn(isOnlyDetach: Bool, isNeedToast: Bool, mode: MenualEntity.ShowToastType) {
        diaryWritingPressedBackBtnCallCount += 1
    }
}

// MARK: - DiaryWritingBuildableMock
final class DiaryWritingBuildableMock: DiaryWritingBuildable {
    var buildHandler: ((_ listener: DiaryWritingListener) -> DiaryWritingRouting)?

    var buildCallCount = 0
    func build(withListener listener: DiaryWriting.DiaryWritingListener, diaryModel: MenualEntity.DiaryModelRealm?, page: Int) -> DiaryWriting.DiaryWritingRouting {
        buildCallCount += 1
        
        if let buildHandler = buildHandler {
            return buildHandler(listener)
        }
        
        fatalError()
    }
}

// MARK: - DiaryWritingRoutingMock
final class DiaryWritingRoutingMock: DiaryWritingRouting {
    // Function Hanlder
    var loadHandler: (() -> ())?
    var loadCallCount: Int = 0
    var attachChildHandler: ((_ child: Routing) -> ())?
    var attachChildCallCount: Int = 0
    var detachChildHanlder: ((_ child: Routing) -> ())?
    var detachChildCallCount: Int = 0

    // Variable
    var viewControllable: RIBs.ViewControllable
    var interactable: RIBs.Interactable {
        didSet { interactableSetCallCount += 1 }
    }
    var interactableSetCallCount: Int = 0
    var childrenCallCount: Int = 0
    var children: [RIBs.Routing] = [Routing]() { didSet { childrenCallCount += 1 }}
    var lifecycleCallCount: Int = 0
    var lifecycle: RxSwift.Observable<RIBs.RouterLifecycle> {
        lifecycleRelay.asObservable()
    }
    private var lifecycleRelay = BehaviorRelay<RouterLifecycle>(value: .didLoad) {
        didSet { lifecycleCallCount += 1}
    }
    
    var attachDiaryTempSaveCallCount: Int = 0
    var detachDiaryTempSaveCallCount: Int = 0
    
    init(
        interactable: Interactable,
        viewControllable: ViewControllable
    ) {
        self.interactable = interactable
        self.viewControllable = viewControllable
    }
    
    func attachDiaryTempSave(tempSaveDiaryModelRelay: RxRelay.BehaviorRelay<MenualEntity.TempSaveModelRealm?>, tempSaveResetRelay: RxRelay.BehaviorRelay<Bool>) {
        attachDiaryTempSaveCallCount += 1
    }
    
    func detachDiaryTempSave(isOnlyDetach: Bool) {
        detachDiaryTempSaveCallCount += 1
    }
    
    func load() {
        loadCallCount += 1
        if let loadHandler = loadHandler {
            return loadHandler()
        }
    }
    
    func attachChild(_ child: RIBs.Routing) {
        attachChildCallCount += 1
        if let attachChildHandler = attachChildHandler {
            return attachChildHandler(child)
        }
    }
    
    func detachChild(_ child: RIBs.Routing) {
        detachChildCallCount += 1
        if let detachChildHanlder = detachChildHanlder {
            return detachChildHanlder(child)
        }
    }
}

// MARK: - DiaryWritingInteractableMock
final class DiaryWritingInteractableMock: DiaryWritingInteractable {
    var isActive: Bool { isActiveRelay.value }
    var isActiveStream: RxSwift.Observable<Bool> { isActiveRelay.asObservable() }
    private let isActiveRelay = BehaviorRelay<Bool>(value: false)
    
    var router: DiaryWriting.DiaryWritingRouting?
    var listener: DiaryWriting.DiaryWritingListener?

    func activate() {
        isActiveRelay.accept(true)
    }
    
    func deactivate() {
        isActiveRelay.accept(false)
    }
    
    var diaryTempSavePressentBackBtnCallCount = 0
    func diaryTempSavePressentBackBtn(isOnlyDetach: Bool) {
        diaryTempSavePressentBackBtnCallCount += 1
    }
}
