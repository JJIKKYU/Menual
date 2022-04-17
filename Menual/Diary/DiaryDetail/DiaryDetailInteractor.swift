//
//  DiaryDetailInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import RIBs
import RxSwift

protocol DiaryDetailRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DiaryDetailPresentable: Presentable {
    var listener: DiaryDetailPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    func pressedBackBtn()
    func loadDiaryDetail(model: DiaryModel)
}

protocol DiaryDetailListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryDetailPressedBackBtn()
}

final class DiaryDetailInteractor: PresentableInteractor<DiaryDetailPresentable>, DiaryDetailInteractable, DiaryDetailPresentableListener {
    
    let diaryModel: DiaryModel?

    weak var router: DiaryDetailRouting?
    weak var listener: DiaryDetailListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryDetailPresentable,
        diaryModel: DiaryModel
    ) {
        self.diaryModel = diaryModel
        super.init(presenter: presenter)
        presenter.listener = self
        
        print("interactor = \(diaryModel)")
        presenter.loadDiaryDetail(model: diaryModel)
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
        listener?.diaryDetailPressedBackBtn()
    }
}
