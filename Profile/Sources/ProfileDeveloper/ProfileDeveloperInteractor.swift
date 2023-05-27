//
//  ProfileDeveloperInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/11/16.
//

import RIBs
import RxSwift
import RxRelay
import Foundation
import MenualEntity
import MenualRepository
import MenualServices
import SwiftyStoreKit

public protocol ProfileDeveloperRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

public protocol ProfileDeveloperPresentable: Presentable {
    var listener: ProfileDeveloperPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
    
}

public protocol ProfileDeveloperListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func profileDeveloperPressedBackBtn(isOnlyDetach: Bool)
}

protocol ProfileDeveloperInteractorDependency {
    var diaryRepository: DiaryRepository { get }
    var iapService: IAPServiceProtocol? { get }
}

public final class ProfileDeveloperInteractor: PresentableInteractor<ProfileDeveloperPresentable>, ProfileDeveloperInteractable, ProfileDeveloperPresentableListener {

    public var tempMenualSetRelay = BehaviorRelay<Bool?>(value: nil)
    public var reminderDataCallRelay = BehaviorRelay<Bool?>(value: nil)
    public var receiptRelay = BehaviorRelay<ReceiptInfo?>(value: nil)
    
    
    weak var router: ProfileDeveloperRouting?
    weak var listener: ProfileDeveloperListener?
    private let disposeBag = DisposeBag()
    private let dependency: ProfileDeveloperInteractorDependency

    init(
        presenter: ProfileDeveloperPresentable,
        dependency: ProfileDeveloperInteractorDependency
    ) {
        self.dependency = dependency
        super.init(presenter: presenter)
        presenter.listener = self
    }

    public override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
        bind()
    }

    public override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    func bind() {
        dependency.iapService?
            .checkPurchasedProducts()
            .subscribe(onNext: { [weak self] receipt in
                guard let self = self else { return }
                self.receiptRelay.accept(receipt)
            })
            .disposed(by: disposeBag)
    }
    
    public func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.profileDeveloperPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }

    public func allMenualRemove() {
        dependency.diaryRepository
            .removeAllDiary()
    }
}
