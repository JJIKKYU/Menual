//
//  ProfileRestoreConfirmBuilder.swift
//  Menual
//
//  Created by 정진균 on 2023/02/26.
//

import Foundation
import RIBs
import MenualRepository

public protocol ProfileRestoreConfirmDependency: Dependency {
    var diaryRepository: DiaryRepository { get }
    var backupRestoreRepository: BackupRestoreRepository { get }
}

public final class ProfileRestoreConfirmComponent: Component<ProfileRestoreConfirmDependency>, ProfileRestoreConfirmInteractorDependency {

    public var diaryRepository: DiaryRepository { dependency.diaryRepository }
    public var backupRestoreRepository: BackupRestoreRepository { dependency.backupRestoreRepository }
}

// MARK: - Builder

public protocol ProfileRestoreConfirmBuildable: Buildable {
    func build(
        withListener listener: ProfileRestoreConfirmListener,
        fileURL: URL?
    ) -> ProfileRestoreConfirmRouting
}

public final class ProfileRestoreConfirmBuilder: Builder<ProfileRestoreConfirmDependency>, ProfileRestoreConfirmBuildable {

    public override init(dependency: ProfileRestoreConfirmDependency) {
        super.init(dependency: dependency)
    }

    public func build(
        withListener listener: ProfileRestoreConfirmListener,
        fileURL: URL?
    ) -> ProfileRestoreConfirmRouting {
        let component = ProfileRestoreConfirmComponent(dependency: dependency)
        let viewController = ProfileRestoreConfirmViewController()
        let interactor = ProfileRestoreConfirmInteractor(
            presenter: viewController,
            dependency: component,
            fileURL: fileURL
        )
        viewController.screenName = "restoreConfirm"
        interactor.listener = listener
        return ProfileRestoreConfirmRouter(
            interactor: interactor,
            viewController: viewController
        )
    }
}
