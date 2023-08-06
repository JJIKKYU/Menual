//
//  ProfileHomeRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/03/20.
//

import DiaryBottomSheet
import Foundation
import MenualUtil
import ProfileBackup
import ProfileDesignSystem
import ProfileDeveloper
import ProfileOpensource
import ProfilePassword
import ProfileRestore
import RIBs

protocol ProfileHomeInteractable: Interactable, ProfilePasswordListener, ProfileDeveloperListener, ProfileOpensourceListener, ProfileBackupListener, ProfileRestoreListener, DesignSystemListener, DiaryBottomSheetListener {
    var router: ProfileHomeRouting? { get set }
    var listener: ProfileHomeListener? { get set }
}

protocol ProfileHomeViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ProfileHomeRouter: ViewableRouter<ProfileHomeInteractable, ProfileHomeViewControllable>, ProfileHomeRouting {
    
    private var navigationControllable: NavigationControllerable?
    
    private let profilePasswordBuildable: ProfilePasswordBuildable
    private var profilePasswordRouting: Routing?
    
    private var profileDeveloperBuildable: ProfileDeveloperBuildable
    private var profileDeveloperRouting: Routing?
    
    private var profileOpensourceBuildable: ProfileOpensourceBuildable
    private var profileOpensourceRouting: Routing?
    
    private var profileBackupBuildable: ProfileBackupBuildable
    private var profileBackupRouting: Routing?
    
    private var profileRestoreBuildable: ProfileRestoreBuildable
    private var profileRestoreRouting: Routing?
    
    private var designSystemBuildable: DesignSystemBuildable
    private var designSystemRouting: Routing?
    
    private var bottomSheetBuildable: DiaryBottomSheetBuildable
    private var bottomSheetRouting: Routing?

    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: ProfileHomeInteractable,
        viewController: ProfileHomeViewControllable,
        profilePasswordBuildable: ProfilePasswordBuildable,
        profileDeveloperBuildable: ProfileDeveloperBuildable,
        profileOpensourceBuildable: ProfileOpensourceBuildable,
        profileBackupBuildable: ProfileBackupBuildable,
        profileRestoreBuildable: ProfileRestoreBuildable,
        designSystemBuildable: DesignSystemBuildable,
        bottomSheetBuildable: DiaryBottomSheetBuildable
    ) {
        self.profilePasswordBuildable = profilePasswordBuildable
        self.profileDeveloperBuildable = profileDeveloperBuildable
        self.profileOpensourceBuildable = profileOpensourceBuildable
        self.profileBackupBuildable = profileBackupBuildable
        self.profileRestoreBuildable = profileRestoreBuildable
        self.designSystemBuildable = designSystemBuildable
        self.bottomSheetBuildable = bottomSheetBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // Bottom Up 으로 스크린을 띄울때
    private func presentInsideNavigation(_ viewControllable: ViewControllable) {
        let navigation = NavigationControllerable(root: viewControllable)
        // navigation.navigationController.presentationController?.delegate = interactor.presentationDelegateProxy
        navigation.navigationController.isNavigationBarHidden = true
        navigation.navigationController.modalPresentationStyle = .fullScreen
        self.navigationControllable = navigation
        
        viewController.present(navigation, animated: true, completion:  nil)
    }
    
    private func dismissPresentedNavigation(completion: (() -> Void)?) {
        if self.navigationControllable == nil {
            return
        }
        
        viewController.dismiss(completion: nil)
        self.navigationControllable = nil
    }
    
    // MARK: - ProfilePassword
    func attachProfilePassword(isPasswordChange: Bool, isPaswwordDisabled: Bool) {
        print("ProfileHome :: attachProfilePassword!")
        if profilePasswordRouting != nil {
            return
        }
        
        let router = profilePasswordBuildable.build(
            withListener: interactor,
            isMainScreen: false,
            isPasswordChange: isPasswordChange,
            isPaswwordDisabled: isPaswwordDisabled
        )
        // viewController.pushViewController(router.viewControllable, animated: true)
        presentInsideNavigation(router.viewControllable)
        
        profilePasswordRouting = router
        attachChild(router)
    }
    
    func detachProfilePassword(isOnlyDetach: Bool) {
        print("ProfileHome :: detachProfilePassword!")
        guard let router = profilePasswordRouting else {
            return
        }
        
        if !isOnlyDetach {
            // viewController.popViewController(animated: true)
            dismissPresentedNavigation(completion: nil)
        }
        
        detachChild(router)
        profilePasswordRouting = nil
    }
    
    // MARK: - ProfileDeveloper (개발자도구)
    func attachProfileDeveloper() {
        if profileDeveloperRouting != nil {
            return
        }
        
        let router = profileDeveloperBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        profileDeveloperRouting = router
        attachChild(router)
    }
    
    func detachProfileDeveloper(isOnlyDetach: Bool) {
        guard let router = profileDeveloperRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        profileDeveloperRouting = nil
    }
    
    // MARK: - Profile Opensource (오픈소스라이브러리 보기)
    func attachProfileOpensource() {
        if profileOpensourceRouting != nil {
            return
        }
        
        let router = profileOpensourceBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        profileOpensourceRouting = router
        attachChild(router)
    }
    
    func detachProfileOpensource(isOnlyDetach: Bool) {
        guard let router = profileOpensourceRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        profileOpensourceRouting = nil
    }
    
    // MARK: - Profile Backup
    func attachProfileBackup() {
        if profileBackupRouting != nil {
            return
        }
        
        let router = profileBackupBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        profileBackupRouting = router
        attachChild(router)
    }
    
    func detachProfileBackup(isOnlyDetach: Bool) {
        guard let router = profileBackupRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        profileBackupRouting = nil
    }
    
    // MARK: - Profile Restore
    func attachProfileRestore() {
        if profileRestoreRouting != nil {
            return
        }
        
        let router = profileRestoreBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        profileRestoreRouting = router
        attachChild(router)
    }
    
    func detachProfileRestore(isOnlyDetach: Bool, isAnimated: Bool) {
        guard let router = profileRestoreRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: isAnimated)
        }
        
        detachChild(router)
        profileRestoreRouting = nil
    }
    
    // MARK: - DesignSystem
    func attachDesignSystem() {
        if designSystemRouting != nil {
            return
        }
        
        let router = designSystemBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        designSystemRouting = router
        attachChild(router)
    }
    
    func detachDesignSystem(isOnlyDetach: Bool) {
        guard let router = designSystemRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        designSystemRouting = nil
    }
    
    // MARK: - DevMode
    func attachBottomSheet(type: MenualBottomSheetType) {
        if bottomSheetRouting != nil {
            return
        }

        DispatchQueue.main.async {
            let router = self.bottomSheetBuildable.build(
                withListener: self.interactor,
                bottomSheetType: type,
                menuComponentRelay: nil
            )
            self.viewController.present(router.viewControllable, animated: false, completion: nil)
            self.bottomSheetRouting = router
            self.attachChild(router)
        }
    }
    
    func detachBottomSheet(isOnlyDetach: Bool) {
        guard let router = bottomSheetRouting,
        let diaryBottomSheetRouter = router as? DiaryBottomSheetRouting else {
            return
        }
        
        DispatchQueue.main.async {
            diaryBottomSheetRouter.viewControllable.dismiss(completion: nil)
        }

        detachChild(router)
        bottomSheetRouting = nil
    }
}
