//
//  ProfileOpensourceInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/11/27.
//

import RIBs
import RxSwift

public protocol ProfileOpensourceRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

public protocol ProfileOpensourcePresentable: Presentable {
    var listener: ProfileOpensourcePresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

public protocol ProfileOpensourceListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func profileOpensourcePressedBackBtn(isOnlyDetach: Bool)
}

public final class ProfileOpensourceInteractor: PresentableInteractor<ProfileOpensourcePresentable>, ProfileOpensourceInteractable, ProfileOpensourcePresentableListener {

    weak var router: ProfileOpensourceRouting?
    weak var listener: ProfileOpensourceListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: ProfileOpensourcePresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    public override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    public override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
    
    public func pressedBackBtn(isOnlyDetach: Bool) {
        listener?.profileOpensourcePressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
}
