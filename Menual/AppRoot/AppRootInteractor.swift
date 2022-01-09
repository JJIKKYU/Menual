//
//  AppRootInteractor.swift
//  Menual
//
//  Created by 정진균 on 2021/12/11.
//

import Foundation
import RIBs
import RxSwift

protocol AppRootRouting: Routing {
    func cleanupViews()
    func attachMainHome()
}

protocol AppRootPresentable: Presentable {
  var listener: AppRootPresentableListener? { get set }
  
}

protocol AppRootListener: AnyObject {
    
}

final class AppRootInteractor: PresentableInteractor<AppRootPresentable>,
                               AppRootInteractable,
                               AppRootPresentableListener,
                               URLHandler {
    func handle(_ url: URL) {
        
    }
    

    weak var router: AppRootRouting?
    weak var listener: AppRootListener?

    // in constructor.
    override init(
        presenter: AppRootPresentable
    ) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        
    }

    override func willResignActive() {
        super.willResignActive()

        router?.cleanupViews()
        // TODO: Pause any business logic.
    }
}
