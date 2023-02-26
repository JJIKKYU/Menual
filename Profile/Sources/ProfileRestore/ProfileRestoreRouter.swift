//
//  ProfileRestoreRouter.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs
import ProfileRestoreConfirm
import Foundation

public protocol ProfileRestoreInteractable: Interactable, ProfileRestoreConfirmListener {
    var router: ProfileRestoreRouting? { get set }
    var listener: ProfileRestoreListener? { get set }
    
    func clearProfileConfirmDetach()
}

public protocol ProfileRestoreViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

public final class ProfileRestoreRouter: ViewableRouter<ProfileRestoreInteractable, ProfileRestoreViewControllable>, ProfileRestoreRouting {
    
    private var profileRestoreConfirmBuildable: ProfileRestoreConfirmBuildable
    private var profileRestoreConfirmRouting: Routing?

    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: ProfileRestoreInteractable,
        viewController: ProfileRestoreViewControllable,
        profileRestoreConfirmBuildable: ProfileRestoreConfirmBuildable
    ) {
        self.profileRestoreConfirmBuildable = profileRestoreConfirmBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
    public func attachProfileConfirm(fileURL: URL?) {
        if profileRestoreConfirmRouting != nil {
            return
        }
        
        let router = profileRestoreConfirmBuildable.build(
            withListener: interactor,
            fileURL: fileURL
        )
        viewController.pushViewController(router.viewControllable, animated: true)
        
        profileRestoreConfirmRouting = router
        attachChild(router)
    }
    
    public func detachProfileConfirm(isOnlyDetach: Bool) {
        guard let router = profileRestoreConfirmRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        profileRestoreConfirmRouting = nil
        // interactor.clearProfileConfirmDetach()
    }
}
