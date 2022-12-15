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
    func goDiaryHome()
}

protocol ProfilePasswordInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

final class ProfilePasswordInteractor: PresentableInteractor<ProfilePasswordPresentable>, ProfilePasswordInteractable, ProfilePasswordPresentableListener {
    
    
    weak var router: ProfilePasswordRouting?
    weak var listener: ProfilePasswordListener?
    private let disposeBag = DisposeBag()
    private let dependency: ProfilePasswordInteractorDependency
    var isMainScreen: BehaviorRelay<Bool>
    var userTypedPasswordRelay: BehaviorRelay<[Int]>
    var userTypedPasswordCurrectRelay: BehaviorRelay<Bool?>
    
    var prevPassword: [Int] = []
    var currentPassword: [Int] = []

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    init(
        presenter: ProfilePasswordPresentable,
        dependency: ProfilePasswordInteractorDependency,
        isMainScreen: Bool
    ) {
        self.userTypedPasswordRelay = BehaviorRelay<[Int]>(value: [])
        self.isMainScreen = BehaviorRelay<Bool>(value: false)
        self.userTypedPasswordCurrectRelay = BehaviorRelay<Bool?>(value: nil)
        self.dependency = dependency
        super.init(presenter: presenter)
        self.isMainScreen.accept(isMainScreen)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        bind()
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
    
    func bind() {
        self.userTypedPasswordRelay
            .filter { $0.count == 4 }
            .subscribe(onNext: { [weak self] passwordArr in
                guard let self = self else { return }
                if !self.isMainScreen.value { return }
                print("ProfilePassword :: relay! = \(passwordArr)")
                
                guard let realmPassword = self.dependency.diaryRepository.password.value else { return }
                print("ProfilePassword :: 유저 비밀번호! = \(realmPassword.password)")
                
                var typedPassword: Int = 0
                for (index, val) in passwordArr.enumerated() {
                    typedPassword += val * Int(pow(10.0, 3.0 - Double(index)))
                }
                print("ProfilePassword :: 입력한 비밀번호! = \(typedPassword)")

                
                if typedPassword == realmPassword.password {
                    print("ProfilePassword :: 됐다!")
                    self.listener?.goDiaryHome()
                    
                } else {
                    self.userTypedPasswordCurrectRelay.accept(false)
                }
                
                
            })
            .disposed(by: disposeBag)
    }
    
    func setPassword(passwordArr: [Int]) {
        print("ProfilePassword :: setPassword! \(passwordArr)")
        var password: Int = 0
        for (index, val) in passwordArr.enumerated() {
            password += val * Int(pow(10.0, 3.0 - Double(index)))
            print("ProfilePassword :: password \(password)")
        }
        
        let passwordModel = PasswordModelRealm(password: password,
                                               isEnabled: true
        )
        
        // 이미 password를 설정한 적이 있다면
        if dependency.diaryRepository.password.value != nil {
            print("ProfilePassword :: 이미 패스워드를 설정하셨군요!")
            dependency.diaryRepository
                .updatePassword(model: passwordModel)
        } else {
            print("ProfilePassword :: 처음 패스워드입니다!")
            dependency.diaryRepository
                .addPassword(model: passwordModel)
        }
        
        
        self.listener?.profilePasswordPressedBackBtn(isOnlyDetach: false)
    }
}
