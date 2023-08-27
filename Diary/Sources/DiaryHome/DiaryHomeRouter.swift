//
//  DiaryHomeRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/01/22.
//

import DiaryBottomSheet
import DiaryDetail
import DiarySearch
import DiaryWriting
import Foundation
import MenualEntity
import MenualUtil
import ProfileHome
import RIBs

protocol DiaryHomeInteractable: Interactable, ProfileHomeListener, DiarySearchListener, DiaryWritingListener, DiaryDetailListener, DiaryBottomSheetListener {
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

    private let diaryWritingBuildable: DiaryWritingBuildable
    private var diaryWritingRouting: Routing?

    private let diaryDetailBuildable: DiaryDetailBuildable
    private var diaryDetailRouting: Routing?

    private let diaryBottomSheetBuildable: DiaryBottomSheetBuildable
    private var diaryBottomSheetRouting: Routing?

    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: DiaryHomeInteractable,
        viewController: DiaryHomeViewControllable,
        profileHomeBuildable: ProfileHomeBuildable,
        diarySearchBuildable: DiarySearchBuildable,
        diaryWritingBuildable: DiaryWritingBuildable,
        diaryDetailBuildable: DiaryDetailBuildable,
        diarybottomSheetBuildable: DiaryBottomSheetBuildable
    ) {
        self.profileHomeBuildable = profileHomeBuildable
        self.diarySearchBuildable = diarySearchBuildable
        self.diaryWritingBuildable = diaryWritingBuildable
        self.diaryDetailBuildable = diaryDetailBuildable
        self.diaryBottomSheetBuildable = diarybottomSheetBuildable

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

    func detachMyPage(isOnlyDetach: Bool, isAnimated: Bool) {
        print("DiaryHomeRouter :: detachMyPage!")
        guard let router = profileHomeRouting else {
            return
        }

        if !isOnlyDetach {
            viewController.popViewController(animated: isAnimated)
        }

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

    // MARK: - Diary Writing 관련 함수
    func attachDiaryWriting(page: Int) {
        print("DiaryHomeRouter :: attachDiaryWriting")
        if diaryWritingRouting != nil {
            return
        }

        let router = diaryWritingBuildable.build(
            withListener: interactor,
            diaryModel: nil,
            page: page
        )
        // Bottom Up 되도록 수정
        presentInsideNavigation(router.viewControllable)
        // viewController.present(router.viewControllable, animated: true, completion: nil)


        diaryWritingRouting = router
        attachChild(router)
    }

    func detachDiaryWriting(isOnlyDetach: Bool) {
        print("DiaryHomeRouter :: detachDiaryWriting")
        guard let router = diaryWritingRouting else {
            return
        }

        // viewController.popViewController(animated: true)
        // viewController.popToRoot(animated: true)
        if !isOnlyDetach {
            dismissPresentedNavigation(completion: nil)
        }
        // dismissPresentedNavigation(completion: nil)
        detachChild(router)

        diaryWritingRouting = nil
    }

    // MARK: - Diary detaill 관련 함수

    func attachDiaryDetail(model: DiaryModelRealm) {
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

    // MARK: - DiaryBottomSheet

    func attachBottomSheet(type: MenualBottomSheetType) {
        if diaryBottomSheetRouting != nil {
            return
        }

        DispatchQueue.main.async {
            let router = self.diaryBottomSheetBuildable.build(
                withListener: self.interactor,
                bottomSheetType: type,
                menuComponentRelay: nil
            )

            self.viewController.present(router.viewControllable,
                                        animated: false,
                                        completion: nil
            )
            self.diaryBottomSheetRouting = router
            self.attachChild(router)
        }
    }

    func detachBottomSheet() {
        guard let router = diaryBottomSheetRouting,
        let diaryBottomSheetRouter = router as? DiaryBottomSheetRouting else {
            return
        }

        DispatchQueue.main.async {
            diaryBottomSheetRouter.viewControllable.dismiss(completion: nil)
        }
        detachChild(router)
        diaryBottomSheetRouting = nil
    }
}
