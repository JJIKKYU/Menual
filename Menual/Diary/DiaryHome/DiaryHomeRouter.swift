//
//  DiaryHomeRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/01/22.
//

import RIBs

protocol DiaryHomeInteractable: Interactable, ProfileHomeListener, DiarySearchListener {
    var router: DiaryHomeRouting? { get set }
    var listener: DiaryHomeListener? { get set }
    var presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy { get }
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
    
    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: DiaryHomeInteractable,
        viewController: DiaryHomeViewControllable,
        profileHomeBuildable: ProfileHomeBuildable,
        diarySearchBuildable: DiarySearchBuildable
    ) {
        self.profileHomeBuildable = profileHomeBuildable
        self.diarySearchBuildable = diarySearchBuildable
        
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
        navigationControllable = NavigationControllerable(root: viewController)
    }
    
    // Bottom Up 으로 스크린을 띄울때
    private func presentInsideNavigation(_ viewControllable: ViewControllable) {
        let navigation = NavigationControllerable(root: viewControllable)
        navigation.navigationController.presentationController?.delegate = interactor.presentationDelegateProxy
        self.navigationControllable = navigation
        viewController.present(navigation, animated: true, completion:  nil)
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
    
    func detachDiarySearch() {
        print("DiaryHomeRouter :: detachDiarySearch")
        guard let router = diarySearchRouting else {
            return
        }
        
        viewController.popViewController(animated: true)
        detachChild(router)
        diarySearchRouting = nil
    }
}
