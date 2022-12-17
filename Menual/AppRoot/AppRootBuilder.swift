//
//  AppRootBuilder.swift
//  Menual
//
//  Created by 정진균 on 2021/12/11.
//

import RIBs
import RxRelay

protocol AppRootDependency: Dependency {
}

// MARK: - Builder

protocol AppRootBuildable: Buildable {
    func build(
        diaryUUIDRelay: BehaviorRelay<String>
    ) -> (
        launchRouter: LaunchRouting,
        urlHandler: URLHandler
    )
}

final class AppRootBuilder: Builder<AppRootDependency>, AppRootBuildable {
    
    override init(dependency: AppRootDependency) {
        super.init(dependency: dependency)
    }

    func build(
        diaryUUIDRelay: BehaviorRelay<String>
    ) -> (
        launchRouter: LaunchRouting,
        urlHandler: URLHandler
    ) {
        
        let viewController = AppRootViewController()
        let component = AppRootComponent(
            dependency: dependency,
            rootViewController: viewController,
            diaryUUIDRelay: diaryUUIDRelay
        )
        
        let interactor = AppRootInteractor(
            presenter: viewController,
            dependency: component
        )
        let profilePassword = ProfilePasswordBuilder(dependency: component)
        let diaryHome = DiaryHomeBuilder(dependency: component)
        
        let router = AppRootRouter(
            interactor: interactor,
            viewController: viewController,
            diaryHome: diaryHome,
            profilePassword: profilePassword,
            diaryUUIDRelay: diaryUUIDRelay
        )
        
        return (router, interactor)
        
        
    }
}
