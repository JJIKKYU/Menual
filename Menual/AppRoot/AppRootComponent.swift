//
//  AppRootComponent.swift
//  Menual
//
//  Created by 정진균 on 2021/12/11.
//

import Foundation
import RIBs

final class AppRootComponent: Component<AppRootDependency> {

    private let rootViewController: ViewControllable
    
    init(
        dependency: AppRootDependency,
        rootViewController: ViewControllable
    ) {
        self.rootViewController = rootViewController
        super.init(dependency: dependency)
    }
}

//MARK: - DiaryWriting Dependency

extension AppRootComponent: DiaryWritingDependency, RegisterHomeDependency, LoginHomeDependency, DiaryHomeDependency {
    var registerHomeBuildable: RegisterHomeBuildable {
        return RegisterHomeBuilder(dependency: self)
    }
    
    var registerHomeBaseController: ViewControllable { rootViewController.topViewControllable }
}
