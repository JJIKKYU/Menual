//
//  DiaryDetailRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import RIBs

protocol DiaryDetailInteractable: Interactable, DiaryBottomSheetListener {
    var router: DiaryDetailRouting? { get set }
    var listener: DiaryDetailListener? { get set }
}

protocol DiaryDetailViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DiaryDetailRouter: ViewableRouter<DiaryDetailInteractable, DiaryDetailViewControllable>, DiaryDetailRouting {
    
    private let diaryBottomSheetBuildable: DiaryBottomSheetBuildable
    private var diaryBottomSheetRouting: Routing?

    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: DiaryDetailInteractable,
        viewController: DiaryDetailViewControllable,
        diarybottomSheetBuildable: DiaryBottomSheetBuildable
    ) {
        self.diaryBottomSheetBuildable = diarybottomSheetBuildable
        
        super.init(
            interactor: interactor,
            viewController: viewController
        )
        interactor.router = self
    }
    
    // MARK: - BottomSheet

    func attachBottomSheet(type: MenualBottomSheetType) {
        if diaryBottomSheetRouting != nil {
            return
        }
        
        let router = diaryBottomSheetBuildable.build(
            withListener: interactor,
            bottomSheetType: type
        )
        
        viewController.present(router.viewControllable,
                               animated: false,
                               completion: nil
        )
        router.viewControllable.uiviewController.modalPresentationStyle = .overFullScreen
        
        diaryBottomSheetRouting = router
        attachChild(router)
    }
    
    func detachBottomSheet() {
        guard let router = diaryBottomSheetRouting,
        let diaryBottomSheetRouter = router as? DiaryBottomSheetRouting else {
            return
        }
        
        diaryBottomSheetRouter.viewControllable.dismiss(completion: nil)
        detachChild(router)
        diaryBottomSheetRouting = nil
    }
}
