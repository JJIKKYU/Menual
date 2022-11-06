//
//  ProfilePasswordInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import RIBs
import RxSwift
import RxRelay

protocol ProfilePasswordRouting: ViewableRouting {

}

protocol ProfilePasswordPresentable: Presentable {
    var listener: ProfilePasswordPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol ProfilePasswordListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func profilePasswordPressedBackBtn(isOnlyDetach: Bool)
}

final class ProfilePasswordInteractor: PresentableInteractor<ProfilePasswordPresentable>, ProfilePasswordInteractable, ProfilePasswordPresentableListener {

    weak var router: ProfilePasswordRouting?
    weak var listener: ProfilePasswordListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: ProfilePasswordPresentable) {
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
    
    func pressedBackBtn(isOnlyDetach: Bool) {
        // detach 하기 위해서 부모에게 넘겨줌
        listener?.profilePasswordPressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
}
