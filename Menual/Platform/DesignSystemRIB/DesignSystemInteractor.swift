//
//  DesignSystemInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import RIBs
import RxSwift
import RxRelay

protocol DesignSystemRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
    func attachBoxButtonVC()
    func detachBoxButtonVC(isOnlyDetach: Bool)
    
    func attachGnbHeaderVC()
    func detachGnbHeaderVC(isOnlyDetach: Bool)
    
    func attachListHeaderVC()
    func detachListHeaderVC(isOnlyDetach: Bool)
    
    func attachMomentsVC()
    func detachMomentsVC(isOnlyDetach: Bool)
}

protocol DesignSystemPresentable: Presentable {
    var listener: DesignSystemPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol DesignSystemListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func designSystemPressedBackBtn(isOnlyDetach: Bool)
}

final class DesignSystemInteractor: PresentableInteractor<DesignSystemPresentable>, DesignSystemInteractable, DesignSystemPresentableListener {

    weak var router: DesignSystemRouting?
    weak var listener: DesignSystemListener?
    private var disposeBag = DisposeBag()
    
    let designSystemVariation = [
        "GNB Header",
        "Badges",
        "Capsule Button",
        "Box Button",
        "Tabs",
        "FAB",
        "List Header",
        "Pagination",
        "Divider",
        "Moments",
        "List"
    ]

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: DesignSystemPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.designSystemPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
    
    func pressedBoxButtonCell() {
        router?.attachBoxButtonVC()
    }
    
    func boxButtonPressedBackBtn(isOnlyDetach: Bool) {
        router?.detachBoxButtonVC(isOnlyDetach: isOnlyDetach)
    }
    
    func pressedGnbHeaderCell() {
        router?.attachGnbHeaderVC()
    }
    
    func gnbHeaderPressedBackBtn(isOnlyDetach: Bool) {
        router?.detachGnbHeaderVC(isOnlyDetach: isOnlyDetach)
    }
    
    func pressedListHeaderCell() {
        router?.attachListHeaderVC()
    }
    
    func listHeaderPressedBackBtn(isOnlyDetach: Bool) {
        router?.detachListHeaderVC(isOnlyDetach: isOnlyDetach)
    }
    
    func pressedMomentsCell() {
        router?.attachMomentsVC()
    }
    
    func momentsPressedBackBtn(isOnlyDetach: Bool) {
        router?.detachMomentsVC(isOnlyDetach: isOnlyDetach)
    }
}
