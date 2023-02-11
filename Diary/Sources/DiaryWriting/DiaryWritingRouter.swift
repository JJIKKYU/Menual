//
//  DiaryWritingRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs
import RxSwift
import RxRelay
import MenualUtil
import MenualEntity
import DiaryTempSave

public protocol DiaryWritingInteractable: Interactable, DiaryTempSaveListener {
    var router: DiaryWritingRouting? { get set }
    var listener: DiaryWritingListener? { get set }
}

public protocol DiaryWritingViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DiaryWritingRouter: ViewableRouter<DiaryWritingInteractable, DiaryWritingViewControllable>, DiaryWritingRouting {
    
    private var navigationControllable: NavigationControllerable?
    
    private let diaryTempSaveBuildable: DiaryTempSaveBuildable
    private var diaryTempSaveRouting: Routing?

    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: DiaryWritingInteractable,
        viewController: DiaryWritingViewControllable,
        diaryTempSaveBuildable: DiaryTempSaveBuildable
    ) {
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
    
    // MARK: - DiaryTempSave
    func attachDiaryTempSave(tempSaveDiaryModelRelay: BehaviorRelay<TempSaveModelRealm?>, tempSaveResetRelay: BehaviorRelay<Bool>) {
        if diaryTempSaveRouting != nil {
            return
        }
        
        let router = diaryTempSaveBuildable.build(
            withListener: interactor,
            tempSaveDiaryModelRelay: tempSaveDiaryModelRelay,
            tempSaveResetRelay: tempSaveResetRelay
        )
        
        // presentInsideNavigation(router.viewControllable)
         viewController.pushViewController(router.viewControllable, animated: true)
        // navigationControllable?.pushViewController(router.viewControllable, animated: true)
        
        diaryTempSaveRouting = router
        attachChild(router)
    }
    
    func detachDiaryTempSave(isOnlyDetach: Bool) {
        guard let router = diaryTempSaveRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewControllable.popViewController(animated: true)
        }

        detachChild(router)
        diaryTempSaveRouting = nil
    }
}
