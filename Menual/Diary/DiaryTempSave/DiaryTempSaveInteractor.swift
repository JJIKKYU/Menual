//
//  DiaryTempSaveInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/05/15.
//

import RIBs
import RxSwift
import RxRelay

protocol DiaryTempSaveRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DiaryTempSavePresentable: Presentable {
    var listener: DiaryTempSavePresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol DiaryTempSaveListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryTempSavePressentBackBtn()
}

protocol DiaryTempSaveInteractorDependecy {
    var diaryRepository: DiaryRepository { get }
}

final class DiaryTempSaveInteractor: PresentableInteractor<DiaryTempSavePresentable>, DiaryTempSaveInteractable, DiaryTempSavePresentableListener {

    weak var router: DiaryTempSaveRouting?
    weak var listener: DiaryTempSaveListener?
    
    private let dependency: DiaryTempSaveDependency
    private let disposeBag = DisposeBag()
    
    var tempSaveRelay = BehaviorRelay<[TempSaveModel]>(value: [])

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryTempSavePresentable,
        dependency: DiaryTempSaveDependency
    ) {
        self.dependency = dependency
        dependency.diaryRepository.fetchTempSave()
        super.init(presenter: presenter)
        presenter.listener = self
        bind()
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func bind() {
        dependency.diaryRepository
            .tempSave
            .subscribe(onNext: { [weak self] tempSave in
                guard let self = self else { return }
                print("TempSave :: tempSave구독! = \(tempSave)")
                self.tempSaveRelay.accept(tempSave)
            })
            .disposed(by: disposeBag)
    }
    
    func pressedBackBtn() {
        listener?.diaryTempSavePressentBackBtn()
    }
}
