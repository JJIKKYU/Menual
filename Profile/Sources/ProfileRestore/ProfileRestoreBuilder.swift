//
//  ProfileRestoreBuilder.swift
//  Menual
//
//  Created by 정진균 on 2023/02/04.
//

import RIBs
import MenualRepository

public protocol ProfileRestoreDependency: Dependency {
    var diaryRepository: DiaryRepository { get }
    var backupRestoreRepository: BackupRestoreRepository { get }
}

public final class ProfileRestoreComponent: Component<ProfileRestoreDependency>, ProfileRestoreInteractorDependency {
    public var diaryRepository: DiaryRepository { dependency.diaryRepository }
    public var backupRestoreRepository: BackupRestoreRepository { dependency.backupRestoreRepository }
}

// MARK: - Builder

public protocol ProfileRestoreBuildable: Buildable {
    func build(withListener listener: ProfileRestoreListener) -> ProfileRestoreRouting
}

public final class ProfileRestoreBuilder: Builder<ProfileRestoreDependency>, ProfileRestoreBuildable {

    public override init(dependency: ProfileRestoreDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ProfileRestoreListener) -> ProfileRestoreRouting {
        let component = ProfileRestoreComponent(dependency: dependency)
        let viewController = ProfileRestoreViewController()
        viewController.screenName = "restore"
        let interactor = ProfileRestoreInteractor(
            presenter: viewController,
            dependency: component
        )
        interactor.listener = listener
        return ProfileRestoreRouter(interactor: interactor, viewController: viewController)
    }
}
