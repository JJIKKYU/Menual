//
//  DiaryDetailImageInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/10/23.
//

import RIBs
import RxSwift
import RxRelay
import Foundation

// MARK: - DiaryDetailImageRouting

public protocol DiaryDetailImageRouting: ViewableRouting {}

// MARK: - DiaryDetailImagePresentable

public protocol DiaryDetailImagePresentable: Presentable {
    var listener: DiaryDetailImagePresentableListener? { get set }
}

// MARK: - DiaryDetailImageListener

public protocol DiaryDetailImageListener: AnyObject {
    func diaryDetailImagePressedBackBtn(isOnlyDetach: Bool)
}

// MARK: - DiaryDetailImageInteractor

final class DiaryDetailImageInteractor: PresentableInteractor<DiaryDetailImagePresentable>, DiaryDetailImageInteractable, DiaryDetailImagePresentableListener {

    weak var router: DiaryDetailImageRouting?
    weak var listener: DiaryDetailImageListener?
    
    let imagesDataRelay: BehaviorRelay<[Data]>
    let selectedIndex: Int
    private let disposeBag = DisposeBag()

    init(
        presenter: DiaryDetailImagePresentable,
        imagesDataRelay: BehaviorRelay<[Data]>,
        selectedIndex: Int
    ) {
        self.imagesDataRelay = imagesDataRelay
        self.selectedIndex = selectedIndex
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        bind()
    }

    override func willResignActive() {
        super.willResignActive()
    }
    
    func bind() {}

    func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.diaryDetailImagePressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
}
