//
//  DiaryHomeRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/01/22.
//

import RIBs

protocol DiaryHomeInteractable: Interactable, ProfileHomeListener, DiarySearchListener, DiaryMomentsListener, DiaryWritingListener, DiaryDetailListener, DesignSystemListener {
    var router: DiaryHomeRouting? { get set }
    var listener: DiaryHomeListener? { get set }
    var presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy { get }
    
    func pressedSearchBtn()
}

protocol DiaryHomeViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DiaryHomeRouter: ViewableRouter<DiaryHomeInteractable, DiaryHomeViewControllable>, DiaryHomeRouting {

    private var navigationControllable: NavigationControllerable?
    
    private let profileHomeBuildable: ProfileHomeBuildable
    private var profileHomeRouting: Routing?
    
    private let diarySearchBuildable: DiarySearchBuildable
    private var diarySearchRouting: Routing?
    
    private let diaryMomentsBuildable: DiaryMomentsBuildable
    private var diaryMomentsRouting: Routing?
    
    private let diaryWritingBuildable: DiaryWritingBuildable
    private var diaryWritingRouting: Routing?
    
    private let diaryDetailBuildable: DiaryDetailBuildable
    private var diaryDetailRouting: Routing?
    
    private let designSystemBuildable: DesignSystemBuildable
    private var designSystemRouting: Routing?
    
    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: DiaryHomeInteractable,
        viewController: DiaryHomeViewControllable,
        profileHomeBuildable: ProfileHomeBuildable,
        diarySearchBuildable: DiarySearchBuildable,
        diaryMomentsBuildable: DiaryMomentsBuildable,
        diaryWritingBuildable: DiaryWritingBuildable,
        diaryDetailBuildable: DiaryDetailBuildable,
        designSystemBuildable: DesignSystemBuildable
    ) {
        self.profileHomeBuildable = profileHomeBuildable
        self.diarySearchBuildable = diarySearchBuildable
        self.diaryMomentsBuildable = diaryMomentsBuildable
        self.diaryWritingBuildable = diaryWritingBuildable
        self.diaryDetailBuildable = diaryDetailBuildable
        self.designSystemBuildable = designSystemBuildable
        
        super.init(
            interactor: interactor,
            viewController: viewController
        )
        interactor.router = self
        navigationControllable = NavigationControllerable(root: viewController)
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

    // MARK: - MyPage (ProfileHome) 관련 함수
    func attachMyPage() {
        print("DiaryHomeRouter :: attachMyPage!")
        if profileHomeRouting != nil {
            return
        }
        
        let router = profileHomeBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        profileHomeRouting = router
        attachChild(router)
    }
    
    func detachMyPage() {
        print("DiaryHomeRouter :: detachMyPage!")
        guard let router = profileHomeRouting else {
            return
        }
        
        viewController.popViewController(animated: true)
        detachChild(router)
        profileHomeRouting = nil
    }
    
    // MARK: - Diary Search (검색화면) 관련 함수
    func attachDiarySearch() {
        print("DiaryHomeRouter :: attachDiarySearch")
        if diarySearchRouting != nil {
            return
        }
        
        let router = diarySearchBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        diarySearchRouting = router
        attachChild(router)
    }
    
    func detachDiarySearch(isOnlyDetach: Bool) {
        print("DiaryHomeRouter :: detachDiarySearch")
        guard let router = diarySearchRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        diarySearchRouting = nil
    }
    
    // MARK: - Diary Moments 관련 함수
    func attachDiaryMoments() {
        print("DiaryHomeRouter :: attachDiaryMoments")
        if diaryMomentsRouting != nil {
            return
        }
        
        let router = diaryMomentsBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        diaryMomentsRouting = router
        attachChild(router)
    }
    
    func detachDiaryMoments() {
        print("DiaryHomeRouter :: detachDiaryMoments")
        guard let router = diaryMomentsRouting else {
            return
        }
        
        viewController.popViewController(animated: true)
        detachChild(router)
        diaryMomentsRouting = nil
    }
    
    // MARK: - Diary Writing 관련 함수
    func attachDiaryWriting() {
        print("DiaryHomeRouter :: attachDiaryWriting")
        if diaryWritingRouting != nil {
            return
        }
        
        let router = diaryWritingBuildable.build(withListener: interactor)
        // Bottom Up 되도록 수정
        presentInsideNavigation(router.viewControllable)
        // viewController.present(router.viewControllable, animated: true, completion: nil)

        
        diaryWritingRouting = router
        attachChild(router)
    }
    
    func detachDiaryWriting() {
        print("DiaryHomeRouter :: detachDiaryWriting")
        guard let router = diaryWritingRouting else {
            return
        }
        
        // viewController.popViewController(animated: true)
        // viewController.popToRoot(animated: true)
        dismissPresentedNavigation(completion: nil)
        detachChild(router)
        
        diaryWritingRouting = nil
    }
    
    // MARK: - Diary detaill 관련 함수
    
    func attachDiaryDetail(model: DiaryModel) {
        if diaryDetailRouting != nil {
            return
        }
        
        let router = diaryDetailBuildable.build(
            withListener: interactor,
            diaryModel: model
        )
        viewController.pushViewController(router.viewControllable, animated: true)
        
        diaryDetailRouting = router
        attachChild(router)
    }
    
    func detachDiaryDetail(isOnlyDetach: Bool) {
        guard let router = diaryDetailRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }

        detachChild(router)
        diaryDetailRouting = nil
    }
    
    // MARK: - DesignSystem RIBs 관련 함수
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
}
