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
    func attachProfilePassword()
    func detachProfilePassword()
}

protocol AppRootPresentable: Presentable {
  var listener: AppRootPresentableListener? { get set }
  
}

protocol AppRootListener: AnyObject {
    
}

protocol AppRootInteractorDependency {
    var diaryRepository: DiaryRepository { get }
}

final class AppRootInteractor: PresentableInteractor<AppRootPresentable>,
                               AppRootInteractable,
                               AppRootPresentableListener,
                               URLHandler {

    
    func handle(_ url: URL) {
        
    }
    

    weak var router: AppRootRouting?
    weak var listener: AppRootListener?
    private let disposeBag = DisposeBag()
    private let dependency: AppRootInteractorDependency

    // in constructor.
    init(
        presenter: AppRootPresentable,
        dependency: AppRootInteractorDependency
    ) {
        self.dependency = dependency
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        
        dependency.diaryRepository.fetchPassword()
        dependency.diaryRepository
            .password
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                
                // password 설정을 안했다면
                if model == nil {
                    self.router?.attachMainHome()
                } else {
                    self.router?.attachProfilePassword()
                }
                print("AppRoot :: model! \(model)")
            })
            .disposed(by: disposeBag)
    }
    
    func goDiaryHome() {
        print("AppRoot :: goDiaryHome!")
        router?.detachProfilePassword()
//        router?.attachMainHome()
    }

    override func willResignActive() {
        super.willResignActive()

        router?.cleanupViews()
        // TODO: Pause any business logic.
        
        
        
    }
    
    func profilePasswordPressedBackBtn(isOnlyDetach: Bool) {
        print("AppRoot :: profilePasswordPressedBackBtn!")
    }
}
