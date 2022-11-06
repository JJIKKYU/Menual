//
//  ProfileHomeRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/03/20.
//

import RIBs

protocol ProfileHomeInteractable: Interactable, ProfilePasswordListener {
    var router: ProfileHomeRouting? { get set }
    var listener: ProfileHomeListener? { get set }
}

protocol ProfileHomeViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class ProfileHomeRouter: ViewableRouter<ProfileHomeInteractable, ProfileHomeViewControllable>, ProfileHomeRouting {
    
    private var navigationControllable: NavigationControllerable?
    
    private let profilePasswordBuildable: ProfilePasswordBuildable
    private var profilePasswordRouting: Routing?

    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: ProfileHomeInteractable,
        viewController: ProfileHomeViewControllable,
        profilePasswordBuildable: ProfilePasswordBuildable
    ) {
        self.profilePasswordBuildable = profilePasswordBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
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
    
    // MARK: - ProfilePassword
    func attachProfilePassword() {
        print("ProfileHome :: attachProfilePassword!")
        if profilePasswordRouting != nil {
            return
        }
        
        let router = profilePasswordBuildable.build(withListener: interactor)
        // viewController.pushViewController(router.viewControllable, animated: true)
        presentInsideNavigation(router.viewControllable)
        
        profilePasswordRouting = router
        attachChild(router)
    }
    
    func detachProfilePassword(isOnlyDetach: Bool) {
        print("ProfileHome :: detachProfilePassword!")
        guard let router = profilePasswordRouting else {
            return
        }
        
        if !isOnlyDetach {
            // viewController.popViewController(animated: true)
            dismissPresentedNavigation(completion: nil)
        }
        
        detachChild(router)
        profilePasswordRouting = nil
    }
}
