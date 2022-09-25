//
//  DiaryDetailRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import RIBs
import RxRelay

protocol DiaryDetailInteractable: Interactable, DiaryBottomSheetListener, DiaryWritingListener {
    var router: DiaryDetailRouting? { get set }
    var listener: DiaryDetailListener? { get set }
}

protocol DiaryDetailViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DiaryDetailRouter: ViewableRouter<DiaryDetailInteractable, DiaryDetailViewControllable>, DiaryDetailRouting {
    
    private let diaryBottomSheetBuildable: DiaryBottomSheetBuildable
    private var diaryBottomSheetRouting: Routing?
    
    private let diaryWritingBuildable: DiaryWritingBuildable
    private var diaryWritingRouting: Routing?

    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: DiaryDetailInteractable,
        viewController: DiaryDetailViewControllable,
        diarybottomSheetBuildable: DiaryBottomSheetBuildable,
        diaryWritingBuildable: DiaryWritingBuildable
    ) {
        self.diaryBottomSheetBuildable = diarybottomSheetBuildable
        self.diaryWritingBuildable = diaryWritingBuildable

        super.init(
            interactor: interactor,
            viewController: viewController
        )
        interactor.router = self
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
    
    func detachBottomSheet() {
        guard let router = diaryBottomSheetRouting,
        let diaryBottomSheetRouter = router as? DiaryBottomSheetRouting else {
            return
        }
        
        diaryBottomSheetRouter.viewControllable.dismiss(completion: nil)
        detachChild(router)
        diaryBottomSheetRouting = nil
    }
    
    // 바텀싯 수정하기
    func attachDiaryWriting(diaryModel: DiaryModel) {
        if diaryWritingRouting != nil {
            return
        }
        print("바텀싯 수정하기! = \(diaryModel)")
        let router = diaryWritingBuildable.build(
            withListener: interactor,
            diaryModel: diaryModel
        )
        viewController.pushViewController(router.viewControllable, animated: true)
        
        diaryWritingRouting = router
        attachChild(router)
    }
    
    func detachDiaryWriting(isOnlyDetach: Bool) {
        guard let router = diaryWritingRouting else {
            return
        }

        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        diaryWritingRouting = nil
    }
}
