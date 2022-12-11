//
//  DiarySearchRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/03/27.
//

import RIBs

protocol DiarySearchInteractable: Interactable, DiaryDetailListener {
    var router: DiarySearchRouting? { get set }
    var listener: DiarySearchListener? { get set }
}

protocol DiarySearchViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DiarySearchRouter: ViewableRouter<DiarySearchInteractable, DiarySearchViewControllable>, DiarySearchRouting {
    
    private let diaryDetailBuildable: DiaryDetailBuildable
    private var diaryDetailRouting: Routing?

    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: DiarySearchInteractable,
        viewController: DiarySearchViewControllable,
        diaryDetailBuildable: DiaryDetailBuildable
    ) {
        self.diaryDetailBuildable = diaryDetailBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    func attachDiaryDetailVC(diaryModel: DiaryModelRealm) {
        if diaryDetailRouting != nil {
            return
        }
        
        let router = diaryDetailBuildable.build(withListener: interactor, diaryModel: diaryModel)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        diaryDetailRouting = router
        attachChild(router)
    }
    
    func detachDiaryDetailVC(isOnlyDetach: Bool) {
        guard let router = diaryDetailRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        diaryDetailRouting = nil
    }
}
