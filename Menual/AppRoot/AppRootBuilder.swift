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
    
    // TODO: - 초기화면 결정
    // 1. 유저가 로그인 상태인지 비로그인 상태인지 판단하고 첫 화면을 띄워줘야 할 것 같다.
    // 2. 비로그인이어도 글쓰기 페이지를 메인 화면으로 갈 거라면... 해놔야겠는데.
    func build() -> (launchRouter: LaunchRouting, urlHandler: URLHandler) {
        
        let viewController = AppRootViewController()
        let component = AppRootComponent(
            dependency: dependency,
            rootViewController: viewController
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
            profilePassword: profilePassword
        )
        
        return (router, interactor)
        
        
    }
}
