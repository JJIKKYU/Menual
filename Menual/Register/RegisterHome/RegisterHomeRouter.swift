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
}

protocol RegisterHomeViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy. Since
    // this RIB does not own its own view, this protocol is conformed to by one of this
    // RIB's ancestor RIBs' view.
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
        navigation.navigationController.modalPresentationStyle = .fullScreen
        // navigation.navigationController.presentationController?.delegate = interactor.prese
        self.navigationControllable = navigation
        viewController.present(navigation, animated: false, completion: nil)
        // viewController.present(registerID.viewControllable, animated: false, completion: nil)
        print("attachRegisterID!, viewcontroller = \(viewController.uiviewController.classForCoder)")
    }
    
    func attachRegisterPW() {
        let registerPW = registerPWBuildable.build(withListener: interactor)
        attachChild(registerPW)
        self.navigationControllable?.pushViewController(registerPW.viewControllable, animated: true)
        
        print("RegisterHome :: attachRegisterPW")
    }
}
