//
//  DiaryMomentsInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/04/03.
//

import RIBs
import RxSwift

protocol DiaryMomentsRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DiaryMomentsPresentable: Presentable {
    var listener: DiaryMomentsPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    func pressedBackBtn()
}

protocol DiaryMomentsListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryMomentsPressedBackBtn()
}

final class DiaryMomentsInteractor: PresentableInteractor<DiaryMomentsPresentable>, DiaryMomentsInteractable, DiaryMomentsPresentableListener {
    
    weak var router: DiaryMomentsRouting?
    weak var listener: DiaryMomentsListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: DiaryMomentsPresentable) {
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
    
    func pressedBackBtn() {
        listener?.diaryMomentsPressedBackBtn()
    }
}
