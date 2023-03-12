//
//  ProfileBackupBuilder.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs
import MenualRepository

public protocol ProfileBackupDependency: Dependency {
    var diaryRepository: DiaryRepository { get }
    var backupRestoreRepository: BackupRestoreRepository { get }
}

public final class ProfileBackupComponent: Component<ProfileBackupDependency>, ProfileBackupInteractorDependency {
    public var diaryRepository: DiaryRepository { dependency.diaryRepository }
    public var backupRestoreRepository: BackupRestoreRepository { dependency.backupRestoreRepository }
    

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

public protocol ProfileBackupBuildable: Buildable {
    func build(withListener listener: ProfileBackupListener) -> ProfileBackupRouting
}

public final class ProfileBackupBuilder: Builder<ProfileBackupDependency>, ProfileBackupBuildable {

    public override init(dependency: ProfileBackupDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ProfileBackupListener) -> ProfileBackupRouting {
        let component = ProfileBackupComponent(dependency: dependency)
        let viewController = ProfileBackupViewController()
        viewController.screenName = "backup"
        let interactor = ProfileBackupInteractor(
            presenter: viewController,
            dependency: component
        )
        interactor.listener = listener
        return ProfileBackupRouter(interactor: interactor, viewController: viewController)
    }
}
