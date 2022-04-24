//
//  DiaryWritingRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs

protocol DiaryWritingInteractable: Interactable, DiaryBottomSheetListener {
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

    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: DiaryWritingInteractable,
        viewController: DiaryWritingViewControllable,
        diaryBottomSheetBuildable: DiaryBottomSheetBuildable
    ) {
        self.diaryBottomSheetBuildable = diaryBottomSheetBuildable
        
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    // MARK: - DiaryBottomSheet
    
    func attachBottomSheet(model: WeatherModel) {
        if diaryBottomSheetRouting != nil {
            return
        }
        
        let router = diaryBottomSheetBuildable.build(
            withListener: interactor,
            weatherModel: model
        )
         viewController.present(router.viewControllable, animated: false, completion: nil)
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
        diaryBottomSheetRouter.viewControllable.dismiss(completion: nil)
        detachChild(router)
        diaryBottomSheetRouting = nil
        
    }
}
