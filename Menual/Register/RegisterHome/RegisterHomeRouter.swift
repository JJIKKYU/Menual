//
//  RegisterHomeRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/02/20.
//

import RIBs

protocol RegisterHomeInteractable: Interactable, RegisterHomeListener, RegisterIDListener, RegisterPWListener {
    var router: RegisterHomeRouting? { get set }
    var listener: RegisterHomeListener? { get set }
    var presentationDelegateProxy: AdaptivePresentationControllerDelegateProxy { get }
}

protocol RegisterHomeViewControllable: ViewControllable {
    
}

final class RegisterHomeRouter: Router<RegisterHomeInteractable>, RegisterHomeRouting {
    // topupRouter가 Push 및 Pop을 할 때 필요하기 때문에, 가지고 있을 것.
    private var navigationControllable: NavigationControllerable?
    
    // 부모가 보내준 뷰컨트롤러
    private let viewController: ViewControllable
    
    private let registerIDBuildable: RegisterIDBuildable
    private let registerPWBuildable: RegisterPWBuildable

    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: RegisterHomeInteractable,
        viewController: ViewControllable,
        registerIDBuilable: RegisterIDBuildable,
        registerPWBuildable: RegisterPWBuildable
    ) {
        self.registerIDBuildable = registerIDBuilable
        self.registerPWBuildable = registerPWBuildable
        self.viewController = viewController
        
        super.init(interactor: interactor)
        interactor.router = self
    }

    func cleanupViews() {
        // TODO: Since this router does not own its view, it needs to cleanup the views
        // it may have added to the view hierarchy, when its interactor is deactivated.
        print("RegisterHome :: CleanupViews")
        if viewController.uiviewController.presentationController != nil,
           navigationControllable != nil {
            navigationControllable?.dismiss(completion: nil)
        }
    }
    
    override func didLoad() {
        super.didLoad()
        attachRegisterID()
        
        print("registerHome didLoad")
    }
    
    func attachRegisterID() {
//         let registerID = RegisterIDBuilder.build(withl)
        let registerID = registerIDBuildable.build(withListener: interactor)
        attachChild(registerID)
        
        let navigation = NavigationControllerable(root: registerID.viewControllable)
        navigation.navigationController.presentationController?.delegate = interactor.presentationDelegateProxy
        // navigation.navigationController.modalPresentationStyle = .fullScreen
        // navigation.navigationController.modalTransitionStyle = .crossDissolve
  
        /*
        navigation.navigationController.navigationBar.backgroundColor = .black
        navigation.navigationController.navigationBar.isTranslucent = false
        navigation.navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigation.navigationController.navigationBar.shadowImage = UIImage()
        navigation.navigationController.navigationBar.tintColor = .white
        navigation.navigationController.navigationBar.barTintColor = .white
        navigation.navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
         */
        
        
        // navigation.navigationController.presentationController?.delegate = interactor.prese
        self.navigationControllable = navigation
        // navigation.pushViewController(registerID.viewControllable, animated: true)
        
        topViewController()?.present(navigation.navigationController, animated: true, completion: nil)
        // viewController.present(registerID.viewControllable, animated: false, completion: nil)
        print("attachRegisterID!, viewcontroller = \(viewController.uiviewController.classForCoder)")
    }
    
    func attachRegisterPW() {
        let registerPW = registerPWBuildable.build(withListener: interactor)
        attachChild(registerPW)
        self.navigationControllable?.pushViewController(registerPW.viewControllable, animated: true)
        
        print("RegisterHome :: attachRegisterPW")
    }
    
    func registerDidClose() {
        print("!!")
    }
    
    func topViewController() -> UIViewController? {
        if let keyWindow = UIApplication.shared.keyWindow {
            if var viewController = keyWindow.rootViewController {
                while viewController.presentedViewController != nil {
                    viewController = viewController.presentedViewController!
                }
                print("topViewController -> \(String(describing: viewController))")
                return viewController
            }
        }
        return nil
    }

}

