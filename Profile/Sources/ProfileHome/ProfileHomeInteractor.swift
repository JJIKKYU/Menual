//
//  ProfileHomeInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/03/20.
//

import DesignSystem
import DiaryBottomSheet
import Foundation
import MenualEntity
import MenualRepository
import MenualServices
import RealmSwift
import RIBs
import RxRelay
import RxSwift

public protocol ProfileHomeRouting: ViewableRouting {
    func attachProfilePassword(isPasswordChange: Bool, isPaswwordDisabled: Bool)
    func detachProfilePassword(isOnlyDetach: Bool)
    
    func attachProfileDeveloper()
    func detachProfileDeveloper(isOnlyDetach: Bool)
    
    func attachProfileOpensource()
    func detachProfileOpensource(isOnlyDetach: Bool)
    
    func attachProfileBackup()
    func detachProfileBackup(isOnlyDetach: Bool)
    
    func attachProfileRestore()
    func detachProfileRestore(isOnlyDetach: Bool, isAnimated: Bool)
    
    func attachDesignSystem()
    func detachDesignSystem(isOnlyDetach: Bool)
    
    func attachBottomSheet(type: MenualBottomSheetType)
    func detachBottomSheet(isOnlyDetach: Bool)
}

protocol ProfileHomePresentable: Presentable {
    var listener: ProfileHomePresentableListener? { get set }
    
    func showToastRestoreSuccess()
    func pressedDeveloperQACell()
}

public protocol ProfileHomeListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
    func profileHomePressedBackBtn(isOnlyDetach: Bool)
    func restoreSuccess()
}

protocol ProfileHomeInteractorDependency {
    var diaryRepository: DiaryRepository { get }
    var profileRepository: ProfileRepository? { get }
    var notificationRepository: NotificationRepository? { get }
    var iapService: IAPServiceProtocol? { get }
}

final class ProfileHomeInteractor: PresentableInteractor<ProfileHomePresentable>, ProfileHomeInteractable, ProfileHomePresentableListener {
    var isEnabledPasswordRelay: BehaviorRelay<Bool>
    
    var profileHomeDataArr_Setting1: [ProfileHomeMenuModel] = []
    var profileHomeDataArr_Setting2: [ProfileHomeMenuModel] = []
    var profileHomeDevDataArr: [ProfileHomeMenuModel] = []
    
    weak var router: ProfileHomeRouting?
    weak var listener: ProfileHomeListener?
    private let disposeBag = DisposeBag()
    private let dependency: ProfileHomeInteractorDependency?
    
    var passwordNotificationToken: NotificationToken? // passwordRealm Noti

    init(
        presenter: ProfileHomePresentable,
        dependency: ProfileHomeInteractorDependency?
    ) {
        self.isEnabledPasswordRelay = BehaviorRelay<Bool>(value: false)
        
        // ProfileHome Menu 세팅
        self.profileHomeDataArr_Setting1 = dependency?.profileRepository?.fetchSetting1ProfileMenu() ?? []
        self.profileHomeDataArr_Setting2 = dependency?.profileRepository?.fetchSetting2ProfileMenu() ?? []
        self.profileHomeDevDataArr = dependency?.profileRepository?.fetchSettingDevModeMenu() ?? []

        self.dependency = dependency
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        bind()
        bindRealm()
        setEnabledPassword()
    }

    override func willResignActive() {
        super.willResignActive()
        passwordNotificationToken = nil
    }
    
    // VC에서 뒤로가기 버튼을 눌렀을경우
    func pressedBackBtn(isOnlyDetach: Bool) {
        // detach 하기 위해서 부모에게 넘겨줌
        listener?.profileHomePressedBackBtn(isOnlyDetach: isOnlyDetach)
    }
    
    func bind() {
//        dependency.diaryRepository
//            .password
//            .subscribe(onNext: { [weak self] passwordModel in
//                guard let self = self else { return }
//                let isEnabled: Bool = passwordModel?.isEnabled ?? false
//                self.isEnabledPasswordRelay.accept(isEnabled)
//            })
//            .disposed(by: disposeBag)
    }

    func bindRealm() {
        guard let realm = Realm.safeInit() else { return }
        let passwordModel = realm.objects(PasswordModelRealm.self)
        passwordNotificationToken = passwordModel
            .observe({ changes in
                switch changes {
                case .initial(let model):
                    // 패스워드가 있을 경우
                    if let model = model.first {
                        self.isEnabledPasswordRelay.accept(model.isEnabled)
                    } else {
                        self.isEnabledPasswordRelay.accept(false)
                    }

                case .update(let model, _, _, let modifications):
                    print("ProfileHome :: modifications = \(modifications), \(model)")
                    guard let model = model.first else { return }
                    self.isEnabledPasswordRelay.accept(model.isEnabled)

                case .error(let error):
                    print("ProfileHome :: PasswordError! = \(error)")
                }
            })
    }
    
    // MARK: - ProfilePassword
    func setEnabledPassword() {
        var isEnabledPassword: Bool = false
        if let passwordModel = dependency?.diaryRepository.password.value {
            isEnabledPassword = passwordModel.isEnabled
        }
        isEnabledPasswordRelay.accept(isEnabledPassword)
    }

    func profilePasswordPressedBackBtn(isOnlyDetach: Bool) {
        print("ProfileHome :: profilePasswordPressedBackBtn")
        router?.detachProfilePassword(isOnlyDetach: isOnlyDetach)
    }

    func pressedProfilePasswordCell() {
        print("ProfileHome :: pressedProfilePasswordCell")
        // 비밀번호 설정을 안했으면 설정할 수 있도록 설정창 띄우기
        if isEnabledPasswordRelay.value == false {
            router?.attachProfilePassword(isPasswordChange: false, isPaswwordDisabled: false)
        }
        // 비밀번호 설정 했으면 비밀번호 설정 Disabled로 변경
        else {
            router?.attachProfilePassword(isPasswordChange: false, isPaswwordDisabled: true)

            /*
            guard let model = dependency.diaryRepository.password.value else { return }

            let newModel = PasswordModelRealm(password: model.password,
                                              isEnabled: false
            )

            dependency.diaryRepository
                .updatePassword(model: newModel)
             */
        }
    }
    
    func pressedProfilePasswordChangeCell() {
        router?.attachProfilePassword(isPasswordChange: true, isPaswwordDisabled: false)
    }
    
    // MARK: - ProfileDeveloper (개발자 도구)
    
    func profileDeveloperPressedBackBtn(isOnlyDetach: Bool) {
        router?.detachProfileDeveloper(isOnlyDetach: isOnlyDetach)
    }
    
    func pressedProfileDeveloperCell() {
        router?.attachProfileDeveloper()
    }
    
    // MARK: - ProfileOpensource (오픈 소스 라이브러리 보기)
    
    func profileOpensourcePressedBackBtn(isOnlyDetach: Bool) {
        router?.detachProfileOpensource(isOnlyDetach: isOnlyDetach)
    }
    
    func pressedProfileOpensourceCell() {
        router?.attachProfileOpensource()
    }
    
    func goDiaryHome() { }
    
    // MARK: - ProfileRestore
    
    func pressedProfileRestoreBackBtn(isOnlyDetach: Bool) {
        router?.detachProfileRestore(isOnlyDetach: isOnlyDetach, isAnimated: true)
    }
    
    func pressedProfileRestoreCell() {
        router?.attachProfileRestore()
    }
    func restoreSuccess() {
        router?.detachProfileRestore(isOnlyDetach: false, isAnimated: false)
        listener?.restoreSuccess()
        // listener?.profileHomePressedBackBtn(isOnlyDetach: false)
        // presenter.showToastRestoreSuccess()
    }
    
    // MARK: - ProfileBackup
    
    func pressedProfileBackupCell() {
        router?.attachProfileBackup()
    }
    
    func pressedProfileBackupBackBtn(isOnlyDetach: Bool) {
        router?.detachProfileBackup(isOnlyDetach: isOnlyDetach)
    }
    
    // MARK: - DesignSystem
    
    func pressedDesignSystemCell() {
        router?.attachDesignSystem()
    }
    
    func designSystemPressedBackBtn(isOnlyDetach: Bool) {
        router?.detachDesignSystem(isOnlyDetach: isOnlyDetach)
    }
    
    // MARK: - DEVMode
    
    func pressedReviewCell() {
        router?.attachBottomSheet(type: .review)
    }
    
    func diaryBottomSheetPressedCloseBtn() {
        router?.detachBottomSheet(isOnlyDetach: false)
    }
    
    func reviewCompoentViewPresentQA() {
        presenter.pressedDeveloperQACell()
    }
    
    func pressedPurchaseCell() {
        dependency?.iapService?
            .getLocalPriceObservable(productID: "com.jjikkyu.menual.ad2")
            .subscribe(onNext: { [weak self] price in
                guard let self = self else { return }
                
                print("iapService :: price = \(price)")
            })
            .disposed(by: disposeBag)
        
        dependency?.iapService?
            .purchase(productID: "com.jjikkyu.menual.ad2")
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                print("iapService :: result = \(result)")
            })
            .disposed(by: disposeBag)
    }
    
    func pressedPurchaseCheckCell() {
        dependency?.iapService?
            .restorePurchaseObservable()
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                print("iapService :: result = \(result)")
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Alarm
    
    func pressedAlarmCell() {
        router?.attachBottomSheet(type: .alarm)
    }
    
    func setAlarm(date: Date, days: [Weekday]) {
        print("ProfileHome :: date = \(date), days = \(days)")
        dependency?.notificationRepository?
            .setAlarm(date: date, days: days)
    }
}


// MARK: - 미사용

extension ProfileHomeInteractor {
    func filterWithWeatherPlace(weatherArr: [MenualEntity.Weather], placeArr: [MenualEntity.Place]) {}
    func filterWithWeatherPlacePressedFilterBtn() {}
    func reminderCompViewshowToast(isEding: Bool) {}
}
