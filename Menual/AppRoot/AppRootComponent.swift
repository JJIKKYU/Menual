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
    var appstoreReviewRepository: AppstoreReviewRepository
    var momentsRepository: MomentsRepository
    var backupRestoreRepository: BackupRestoreRepository
    var diaryUUIDRelay: BehaviorRelay<String>
    var containerRepository: ContainerRepository
    
    init(
        dependency: AppRootDependency,
        rootViewController: ViewControllable,
        diaryUUIDRelay: BehaviorRelay<String>
    ) {
        self.diaryUUIDRelay = diaryUUIDRelay
        self.rootViewController = rootViewController
        self.diaryRepository = DiaryRepositoryImp()
        self.containerRepository = ContainerRepositoryImp()
        self.momentsRepository = MomentsRepositoryImp()
        self.appstoreReviewRepository = AppstoreReviewRepositoryImp()
        self.backupRestoreRepository = BackupRestoreRepositoryImp()
        self.momentsRepository.fetch()
        super.init(dependency: dependency)
    }
}

extension AppRootComponent: DiaryHomeDependency,
                            ProfilePasswordDependency,
                            AppRootInteractorDependency, SplashDependency
{
    
    
    

    
}
