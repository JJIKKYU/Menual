//
//  DiaryWritingRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs
import RxSwift
import RxRelay

protocol DiaryWritingInteractable: Interactable, DiaryBottomSheetListener, DiaryTempSaveListener {
    var router: DiaryWritingRouting? { get set }
    var listener: DiaryWritingListener? { get set }
}

protocol DiaryWritingViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DiaryWritingRouter: ViewableRouter<DiaryWritingInteractable, DiaryWritingViewControllable>, DiaryWritingRouting {
    
    private var navigationControllable: NavigationControllerable?
    
    private let diaryBottomSheetBuildable: DiaryBottomSheetBuildable
    private var diaryBottomSheetRouting: Routing?
    
    private let diaryTempSaveBuildable: DiaryTempSaveBuildable
    private var diaryTempSaveRouting: Routing?

    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: DiaryWritingInteractable,
        viewController: DiaryWritingViewControllable,
        diaryBottomSheetBuildable: DiaryBottomSheetBuildable,
        diaryTempSaveBuildable: DiaryTempSaveBuildable
    ) {
        self.diaryBottomSheetBuildable = diaryBottomSheetBuildable
        self.diaryTempSaveBuildable = diaryTempSaveBuildable
        
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // Bottom Up 으로 스크린을 띄울때
    private func presentInsideNavigation(_ viewControllable: ViewControllable) {
        let navigation = NavigationControllerable(root: viewControllable)
        // navigation.navigationController.presentationController?.delegate = interactor.presentationDelegateProxy
        navigation.navigationController.isNavigationBarHidden = true
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
    
    // MARK: - DiaryBottomSheet
    
    func attachBottomSheet(weatherModelOb: BehaviorRelay<WeatherModel?>, placeModelOb: BehaviorRelay<PlaceModel?>, bottomSheetType: MenualBottomSheetType) {
        if diaryBottomSheetRouting != nil {
            return
        }
        
        let router = diaryBottomSheetBuildable.build(
            withListener: interactor,
            bottomSheetType: bottomSheetType,
            menuComponentRelay: nil
        )
         viewController.present(router.viewControllable, animated: false, completion: nil)
        router.viewControllable.uiviewController.modalPresentationStyle = .overFullScreen
        // presentInsideNavigation(router.viewControllable)
        
        diaryBottomSheetRouting = router
        attachChild(router)
    }
    
    func detachBottomSheet() {
        guard let router = diaryBottomSheetRouting,
              let diaryBottomSheetRouter = diaryBottomSheetRouting as? DiaryBottomSheetRouting else {
            return
        }
        print("detachBottomSheet")
        
        // CustomUI Transition 보장
        diaryBottomSheetRouter.viewControllable.dismiss(completion: nil)
        self.detachChild(router)
        self.diaryBottomSheetRouting = nil
    }
    
    // MARK: - DiaryTempSave
    func attachDiaryTempSave() {
        if diaryTempSaveRouting != nil {
            return
        }
        
        let router = diaryTempSaveBuildable.build(withListener: interactor)
        
        // presentInsideNavigation(router.viewControllable)
         viewController.pushViewController(router.viewControllable, animated: true)
        // navigationControllable?.pushViewController(router.viewControllable, animated: true)
        
        diaryTempSaveRouting = router
        attachChild(router)
    }
    
    func detachDiaryTempSave() {
        guard let router = diaryTempSaveRouting else {
            return
        }
        
        viewControllable.popViewController(animated: true)
        detachChild(router)
        diaryTempSaveRouting = nil
    }
}
