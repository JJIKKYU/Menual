//
//  DiaryWritingInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs
import RxSwift

protocol DiaryWritingRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DiaryWritingPresentable: Presentable {
    var listener: DiaryWritingPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol DiaryWritingListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class DiaryWritingInteractor: PresentableInteractor<DiaryWritingPresentable>, DiaryWritingInteractable, DiaryWritingPresentableListener {

    weak var router: DiaryWritingRouting?
    weak var listener: DiaryWritingListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: DiaryWritingPresentable) {
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
}
