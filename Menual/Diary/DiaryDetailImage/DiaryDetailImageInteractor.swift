//
//  DiaryDetailImageInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/10/23.
//

import RIBs
import RxSwift
import RxRelay

protocol DiaryDetailImageRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol DiaryDetailImagePresentable: Presentable {
    var listener: DiaryDetailImagePresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    func setImage(imageData: Data)
}

protocol DiaryDetailImageListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func diaryDetailImagePressedBackBtn(isOnlyDetach: Bool)
}

final class DiaryDetailImageInteractor: PresentableInteractor<DiaryDetailImagePresentable>, DiaryDetailImageInteractable, DiaryDetailImagePresentableListener {

    weak var router: DiaryDetailImageRouting?
    weak var listener: DiaryDetailImageListener?
    
    let imageDataRelay: BehaviorRelay<Data>
    private let disposeBag = DisposeBag()

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: DiaryDetailImagePresentable,
        imageDataRelay: BehaviorRelay<Data>
    ) {
        self.imageDataRelay = imageDataRelay
        super.init(presenter: presenter)
        presenter.listener = self
        // presenter.setImage(imageData: imageData)
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        bind()
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func bind() {
        imageDataRelay
            .subscribe(onNext: { [weak self] imageData in
                guard let self = self else { return }
                print("DiaryDetailImage :: imageData = \(imageData)")
                self.presenter.setImage(imageData: imageData)
            })
            .disposed(by: disposeBag)
    }
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.diaryDetailImagePressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
}
