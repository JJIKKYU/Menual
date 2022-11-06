//
//  ProfileHomeInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/03/20.
//

import RIBs
import RxSwift

protocol ProfileHomeRouting: ViewableRouting {
    func attachProfilePassword()
    func detachProfilePassword(isOnlyDetach: Bool)
}

protocol ProfileHomePresentable: Presentable {
    var listener: ProfileHomePresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol ProfileHomeListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func profileHomePressedBackBtn(isOnlyDetach: Bool)
}

protocol ProfileHomeInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

final class ProfileHomeInteractor: PresentableInteractor<ProfileHomePresentable>, ProfileHomeInteractable, ProfileHomePresentableListener {
    
    var profileHomeDataArr_Setting1: [ProfileHomeModel] {
        let arr: [ProfileHomeModel] = [
            ProfileHomeModel(section: .SETTING1, type: .arrow, title: "메뉴얼 가이드 보기"),
            ProfileHomeModel(section: .SETTING1, type: .toggle, title: "비밀번호 설정하기"),
            ProfileHomeModel(section: .SETTING1, type: .arrow, title: "비밀번호 변경하기"),
        ]

        return arr
    }
    
    var profileHomeDataArr_Setting2: [ProfileHomeModel] {
        let arr: [ProfileHomeModel] = [
            ProfileHomeModel(section: .SETTING2, type: .arrow, title: "iCloud 동기화하기"),
            ProfileHomeModel(section: .SETTING2, type: .arrow, title: "메뉴얼 백업하기"),
            ProfileHomeModel(section: .SETTING2, type: .arrow, title: "메뉴얼 내보내기"),
            ProfileHomeModel(section: .SETTING2, type: .arrow, title: "개발자에게 문의하기"),
            ProfileHomeModel(section: .SETTING2, type: .arrow, title: "오픈 소스 라이브러리 보기"),
        ]

        return arr
    }
    
    weak var router: ProfileHomeRouting?
    weak var listener: ProfileHomeListener?
    private let dependency: ProfileHomeInteractorDependency

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: ProfileHomePresentable,
        dependency: ProfileHomeInteractorDependency
    ) {
        self.dependency = dependency
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
    
    // VC에서 뒤로가기 버튼을 눌렀을경우
    func pressedBackBtn(isOnlyDetach: Bool) {
        // detach 하기 위해서 부모에게 넘겨줌
        listener?.profileHomePressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
    
    // MARK: - ProfilePassword

    func profilePasswordPressedBackBtn(isOnlyDetach: Bool) {
        print("ProfileHome :: profilePasswordPressedBackBtn")
        router?.detachProfilePassword(isOnlyDetach: isOnlyDetach)
    }
    func pressedProfilePasswordCell() {
        print("ProfileHome :: pressedProfilePasswordCell")
        router?.attachProfilePassword()
    }
    
    func goDiaryHome() { }
}
