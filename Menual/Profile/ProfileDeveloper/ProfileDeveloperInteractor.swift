//
//  ProfileDeveloperInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/11/16.
//

import RIBs
import RxSwift

protocol ProfileDeveloperRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

protocol ProfileDeveloperPresentable: Presentable {
    var listener: ProfileDeveloperPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol ProfileDeveloperListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class ProfileDeveloperInteractor: PresentableInteractor<ProfileDeveloperPresentable>, ProfileDeveloperInteractable, ProfileDeveloperPresentableListener {

    weak var router: ProfileDeveloperRouting?
    weak var listener: ProfileDeveloperListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: ProfileDeveloperPresentable) {
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
