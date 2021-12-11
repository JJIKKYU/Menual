//
//  AppRootBuilder.swift
//  Menual
//
//  Created by 정진균 on 2021/12/11.
//

import RIBs

protocol AppRootDependency: Dependency {

}

// MARK: - Builder

protocol AppRootBuildable: Buildable {
    func build() -> (launchRouter: LaunchRouting, urlHandler: URLHandler)
}

final class AppRootBuilder: Builder<AppRootDependency>, AppRootBuildable {
    
    override init(dependency: AppRootDependency) {
        super.init(dependency: dependency)
    }
    
    func build() -> (launchRouter: LaunchRouting, urlHandler: URLHandler) {
        
        print("AppRootBuild!")
        
        let tabBar = RootTabBarController()
        
        let component = AppRootComponent(
            dependency: dependency,
            rootViewController: tabBar
        )
        
        let interactor = AppRootInteractor(presenter: tabBar)
        
        let router = AppRootRouter(
            interactor: interactor,
            viewController: tabBar
        )
        
        return (router, interactor)
        
        
    }
}
