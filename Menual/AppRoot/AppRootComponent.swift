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
    var diaryRepository: DiaryRepository
    
    init(
        dependency: AppRootDependency,
        rootViewController: ViewControllable
    ) {
        self.rootViewController = rootViewController
        self.diaryRepository = DiaryRepositoryImp()
        self.diaryRepository.fetch()
        super.init(dependency: dependency)
    }
}

extension AppRootComponent: DiaryHomeDependency,
                            ProfilePasswordDependency,
                            AppRootInteractorDependency
{
    
    var registerHomeBaseController: ViewControllable { rootViewController.topViewControllable }
}
