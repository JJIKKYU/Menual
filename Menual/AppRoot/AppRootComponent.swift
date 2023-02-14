//
//  AppRootComponent.swift
//  Menual
//
//  Created by 정진균 on 2021/12/11.
//

import Foundation
import RIBs
import RxRelay
import MenualRepository
import ProfilePassword
import DiaryHome

final class AppRootComponent: Component<AppRootDependency> {

    private let rootViewController: ViewControllable
    var diaryRepository: DiaryRepository
    var momentsRepository: MomentsRepository
    var diaryUUIDRelay: BehaviorRelay<String>
    
    init(
        dependency: AppRootDependency,
        rootViewController: ViewControllable,
        diaryUUIDRelay: BehaviorRelay<String>
    ) {
        self.diaryUUIDRelay = diaryUUIDRelay
        self.rootViewController = rootViewController
        self.diaryRepository = DiaryRepositoryImp()
        self.momentsRepository = MomentsRepositoryImp()
        self.momentsRepository.fetch()
        super.init(dependency: dependency)
    }
}

extension AppRootComponent: DiaryHomeDependency,
                            ProfilePasswordDependency,
                            AppRootInteractorDependency, SplashDependency
{

    
}
