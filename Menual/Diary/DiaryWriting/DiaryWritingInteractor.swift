//
//  DiaryWritingInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs
import RxSwift
import RealmSwift

protocol DiaryWritingRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DiaryWritingPresentable: Presentable {
    var listener: DiaryWritingPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    func pressedBackBtn()
}

protocol DiaryWritingListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryWritingPressedBackBtn()
}

protocol DiaryWritingInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

final class DiaryWritingInteractor: PresentableInteractor<DiaryWritingPresentable>, DiaryWritingInteractable, DiaryWritingPresentableListener {
    
    weak var router: DiaryWritingRouting?
    weak var listener: DiaryWritingListener?
    private let dependency: DiaryWritingInteractorDependency
    private var disposebag: DisposeBag

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryWritingPresentable,
        dependency: DiaryWritingInteractorDependency
    ) {
        self.dependency = dependency
        self.disposebag = DisposeBag()
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
        listener?.diaryWritingPressedBackBtn()
    }
    
    func writeDiary(info: DiaryModel) {
        print("DiaryWritingInteractor :: writeDiary! info = \(info)")
        
        dependency.diaryRepository
            .addDiary(info: info)
        listener?.diaryWritingPressedBackBtn()
    }
}
