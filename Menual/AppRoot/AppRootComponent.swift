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
import DiaryHome

final class AppRootComponent: Component<AppRootDependency> {

    private let rootViewController: ViewControllable
    var diaryRepository: DiaryRepository
    var migrationRepository: MigrationRepository?
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
        self.migrationRepository = containerRepository.container.resolve(MigrationRepository.self)
        super.init(dependency: dependency)
    }
}

extension AppRootComponent: DiaryHomeDependency, AppRootInteractorDependency, SplashDependency
{}
