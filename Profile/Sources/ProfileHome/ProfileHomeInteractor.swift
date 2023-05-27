//
//  ProfileHomeInteractor.swift
//  Menual
//
//  Created by 정진균 on 2022/03/20.
//

import RIBs
import RxSwift
import RxRelay
import RealmSwift
import DesignSystem
import MenualRepository
import MenualEntity
import MenualServices

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
    
    func attachReviewBottomSheet()
    func detachReviewBottomSheet(isOnlyDetach: Bool)
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
    var containerRepository: ContainerRepository { get }
    var iapService: IAPServiceProtocol? { get }
}

final class ProfileHomeInteractor: PresentableInteractor<ProfileHomePresentable>, ProfileHomeInteractable, ProfileHomePresentableListener {

    var isEnabledPasswordRelay: BehaviorRelay<Bool>
    
    var profileHomeDataArr_Setting1: [ProfileHomeModel] {
        let arr: [ProfileHomeModel] = [
            ProfileHomeModel(section: .SETTING1, type: .arrow, title: MenualString.profile_button_guide, actionName: "showGuide"),
            ProfileHomeModel(section: .SETTING1, type: .toggle, title: MenualString.profile_button_set_password, actionName: "setPassword"),
            ProfileHomeModel(section: .SETTING1, type: .arrow, title: MenualString.profile_button_change_password, actionName: "changePassword"),
        ]

        return arr
    }
    
    var profileHomeDataArr_Setting2: [ProfileHomeModel] {
        let arr: [ProfileHomeModel] = [
            // profileHomeModel(section: .SETTING2, type: .arrow, title: "iCloud 동기화하기"),
            ProfileHomeModel(section: .SETTING2, type: .arrow, title: MenualString.profile_button_backup, actionName: "backup"),
            ProfileHomeModel(section: .SETTING2, type: .arrow, title: MenualString.profile_button_restore, actionName: "load"),
            ProfileHomeModel(section: .SETTING2, type: .arrow, title: MenualString.profile_button_mail, actionName: "mail"),
            ProfileHomeModel(section: .SETTING2, type: .arrow, title: MenualString.profile_button_openSource, actionName: "openSource"),
            // ProfileHomeModel(section: .SETTING2, type: .arrow, title: "개발자 도구"),
        ]

        return arr
    }
    
    var profileHomeDevDataArr: [ProfileHomeModel] {
        let arr: [ProfileHomeModel] = [
            ProfileHomeModel(section: .DEV, type: .arrow, title: "개발자 도구", actionName: "devTools"),
            ProfileHomeModel(section: .DEV, type: .arrow, title: "디자인 시스템", actionName: "designSystem"),
            ProfileHomeModel(section: .DEV, type: .arrow, title: "리뷰 요청", actionName: "review"),
            ProfileHomeModel(section: .DEV, type: .arrow, title: "구독 확인", actionName: "storeCheck"),
            ProfileHomeModel(section: .DEV, type: .arrow, title: "결제하기", actionName: "storeBuy"),
            
        ]
        
        return arr
    }
    
    weak var router: ProfileHomeRouting?
    weak var listener: ProfileHomeListener?
    private let disposeBag = DisposeBag()
    private let dependency: ProfileHomeInteractorDependency
    
    var passwordNotificationToken: NotificationToken? // passwordRealm Noti

    init(
        presenter: ProfileHomePresentable,
        dependency: ProfileHomeInteractorDependency
    ) {
        self.isEnabledPasswordRelay = BehaviorRelay<Bool>(value: false)
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
        dependency.iapService?
            .getPaymentStateObservable()
            .subscribe(onNext: { [weak self] state in
                print("iapService :: test! = \(state)")
                switch state {
                case .purchased, .restored:
                    break
                    
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        dependency.iapService?
            .checkIfPurchased(productID: "com.jjikkyu.menual")
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                
            })
            .disposed(by: disposeBag)
        
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
//            .observe({ [weak self] changes in
//                guard let self = self else { return }
//                switch changes {
//                case .change(let model, let propertyChanges):
//                    print("ProfileHome :: change! = \(model), \(propertyChanges) - 1")
//                    guard let model = model as? PasswordModelRealm else { return }
//                    print("ProfileHome :: change! = \(model), \(propertyChanges) - 2")
//                    self.isEnabledPasswordRelay.accept(model.isEnabled)
//                case .deleted:
//                    self.isEnabledPasswordRelay.accept(false)
//                case .error(let error):
//                    print("ProfileHome :: error! = \(error)")
//                }
//            })
            
            
    }
    
    // MARK: - ProfilePassword
    func setEnabledPassword() {
        var isEnabledPassword: Bool = false
        if let passwordModel = dependency.diaryRepository.password.value {
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
        router?.attachReviewBottomSheet()
    }
    
    func diaryBottomSheetPressedCloseBtn() {
        router?.detachReviewBottomSheet(isOnlyDetach: false)
    }
    
    func reviewCompoentViewPresentQA() {
        presenter.pressedDeveloperQACell()
    }
    
    func pressedPurchaseCell() {
        dependency.iapService?
            .getLocalPriceObservable(productID: "com.jjikkyu.menual.ad2")
            .subscribe(onNext: { [weak self] price in
                guard let self = self else { return }
                
                print("iapService :: price = \(price)")
            })
            .disposed(by: disposeBag)
        
        dependency.iapService?
            .purchase(productID: "com.jjikkyu.menual.ad2")
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                print("iapService :: result = \(result)")
            })
            .disposed(by: disposeBag)
    }
    
    func pressedPurchaseCheckCell() {
        dependency.iapService?
            .restorePurchaseObservable()
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                print("iapService :: result = \(result)")
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - 미사용
extension ProfileHomeInteractor {
    func filterWithWeatherPlace(weatherArr: [MenualEntity.Weather], placeArr: [MenualEntity.Place]) {
    }
    
    func filterWithWeatherPlacePressedFilterBtn() {
        
    }
    
    func reminderCompViewshowToast(isEding: Bool) {
        
    }
    
    func filterDatePressedFilterBtn(yearDateFormatString: String) {
        
    }
}
