//
//  DiaryDetailRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import RIBs
import RxRelay

protocol DiaryDetailInteractable: Interactable, DiaryBottomSheetListener, DiaryWritingListener, DiaryDetailImageListener {
    var router: DiaryDetailRouting? { get set }
    var listener: DiaryDetailListener? { get set }
    func pressedBackBtn(isOnlyDetach: Bool)
    
    var presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy { get }
}

protocol DiaryDetailViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DiaryDetailRouter: ViewableRouter<DiaryDetailInteractable, DiaryDetailViewControllable>, DiaryDetailRouting {
    
    private var navigationControllable: NavigationControllerable?
    
    private let diaryBottomSheetBuildable: DiaryBottomSheetBuildable
    private var diaryBottomSheetRouting: Routing?
    
    private let diaryWritingBuildable: DiaryWritingBuildable
    private var diaryWritingRouting: Routing?
    
    private let diaryDetailImageBuildable: DiaryDetailImageBuildable
    private var diaryDetailImageRouting: Routing?

    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: DiaryDetailInteractable,
        viewController: DiaryDetailViewControllable,
        diarybottomSheetBuildable: DiaryBottomSheetBuildable,
        diaryWritingBuildable: DiaryWritingBuildable,
        diaryDetailImageBuildable: DiaryDetailImageBuildable
    ) {
        self.diaryBottomSheetBuildable = diarybottomSheetBuildable
        self.diaryWritingBuildable = diaryWritingBuildable
        self.diaryDetailImageBuildable = diaryDetailImageBuildable

        super.init(
            interactor: interactor,
            viewController: viewController
        )
        interactor.router = self
    }
    
    // Bottom Up 으로 스크린을 띄울때
    private func presentInsideNavigation(_ viewControllable: ViewControllable, style: UIModalPresentationStyle) {
        let navigation = NavigationControllerable(root: viewControllable)
        // navigation.navigationController.presentationController?.delegate = interactor.presentationDelegateProxy
        navigation.navigationController.isNavigationBarHidden = true
        navigation.navigationController.modalPresentationStyle = style
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
    
    // MARK: - BottomSheet

    func attachBottomSheet(type: MenualBottomSheetType, menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>?) {
        if diaryBottomSheetRouting != nil {
            return
        }
        
        let router = diaryBottomSheetBuildable.build(
            withListener: interactor,
            bottomSheetType: type,
            menuComponentRelay: menuComponentRelay
        )
        
        viewController.present(router.viewControllable,
                               animated: false,
                               completion: nil
        )
        router.viewControllable.uiviewController.modalPresentationStyle = .overFullScreen
        
        diaryBottomSheetRouting = router
        attachChild(router)
    }
    
    func detachBottomSheet(isWithDiaryDetatil: Bool) {
        guard let router = diaryBottomSheetRouting,
        let diaryBottomSheetRouter = router as? DiaryBottomSheetRouting else {
            return
        }
        
        diaryBottomSheetRouter.viewControllable.dismiss {
            print("!!")
            if isWithDiaryDetatil {
                self.interactor.pressedBackBtn(isOnlyDetach: false)
            }
        }
        detachChild(router)
        diaryBottomSheetRouting = nil
    }
    
    // 바텀싯 수정하기
    func attachDiaryWriting(diaryModel: DiaryModel, page: Int) {
        if diaryWritingRouting != nil {
            return
        }
        print("바텀싯 수정하기! = \(diaryModel)")
        let router = diaryWritingBuildable.build(
            withListener: interactor,
            diaryModel: diaryModel,
            page: page
        )

        presentInsideNavigation(router.viewControllable, style: .fullScreen)
        // viewController.present(router.viewControllable, animated: true, completion: nil)
        // viewController.pushViewController(router.viewControllable, animated: true)
        
        diaryWritingRouting = router
        attachChild(router)
    }
    
    func detachDiaryWriting(isOnlyDetach: Bool) {
        guard let router = diaryWritingRouting else {
            return
        }

        if !isOnlyDetach {
            dismissPresentedNavigation(completion: nil)
        }
        
        detachChild(router)
        diaryWritingRouting = nil
    }
    
    // MARK: - 이미지 자세히 보기
    func attachDiaryDetailImage(imageDataRelay: BehaviorRelay<Data>) {
        if diaryDetailImageRouting != nil {
            return
        }
        
        let router = diaryDetailImageBuildable.build(
            withListener: interactor,
            imageDataRelay: imageDataRelay
        )

        let navigation = NavigationControllerable(root: router.viewControllable)
        navigation.navigationController.presentationController?.delegate = interactor.presentationDelegateProxy
        viewControllable.present(navigation, animated: true, completion: nil)
        // presentInsideNavigation(navigation, style: .popover)
        
        diaryDetailImageRouting = router
        attachChild(router)
        
    }
    
    func detachDiaryDetailImage(isOnlyDetach: Bool) {
        guard let router = diaryDetailImageRouting else {
            return
        }
        
        if !isOnlyDetach {
            // dismissPresentedNavigation(completion: nil)
            viewControllable.dismiss(completion: nil)
        }
        
        detachChild(router)
        diaryDetailImageRouting = nil
    }
}
