//
//  ProfileHomeBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/03/20.
//

import RIBs
import RxRelay
import MenualEntity
import MenualRepository
import ProfileOpensource
import ProfilePassword
import ProfileDeveloper
import ProfileBackup
import ProfileRestore
import ProfileDesignSystem
import DiaryBottomSheet
import MenualServices

public protocol ProfileHomeDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var diaryRepository: DiaryRepository { get }
    var containerRepository: ContainerRepository { get }
    var appstoreReviewRepository: AppstoreReviewRepository { get }
    var backupRestoreRepository: BackupRestoreRepository { get }
}

public final class ProfileHomeComponent: Component<ProfileHomeDependency>, ProfilePasswordDependency, ProfileDeveloperDependency, ProfileHomeInteractorDependency, ProfileOpensourceDependency, ProfileBackupDependency, ProfileRestoreDependency, DesignSystemDependency, DiaryBottomSheetDependency {

    public var filteredDiaryCountRelay: BehaviorRelay<Int>?
    public var filteredWeatherArrRelay: BehaviorRelay<[Weather]>?
    public var filteredPlaceArrRelay: BehaviorRelay<[Place]>?
    public var iapService: IAPServiceProtocol? {
        containerRepository.container.resolve(IAPServiceProtocol.self)
    }
    

    public var backupRestoreRepository: BackupRestoreRepository { dependency.backupRestoreRepository }
    public var diaryRepository: DiaryRepository { dependency.diaryRepository }
    public var containerRepository: ContainerRepository { dependency.containerRepository }
    public var appstoreReviewRepository: AppstoreReviewRepository { dependency.appstoreReviewRepository }
}

// MARK: - Builder

public protocol ProfileHomeBuildable: Buildable {
    func build(
        withListener listener: ProfileHomeListener
    ) -> ProfileHomeRouting
}

public final class ProfileHomeBuilder: Builder<ProfileHomeDependency>, ProfileHomeBuildable {

    public override init(dependency: ProfileHomeDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: ProfileHomeListener) -> ProfileHomeRouting {
        let component = ProfileHomeComponent(dependency: dependency)
        
        let profilePasswordBuildable = ProfilePasswordBuilder(dependency: component)
        let profileDveloperBuildable = ProfileDeveloperBuilder(dependency: component)
        let profileOpensourceBuildable = ProfileOpensourceBuilder(dependency: component)
        let profileBackupBuildable = ProfileBackupBuilder(dependency: component)
        let profileRestoreBuildable = ProfileRestoreBuilder(dependency: component)
        let designSystemBuildable = DesignSystemBuilder(dependency: component)
        let bottomSheetBuildable = DiaryBottomSheetBuilder(dependency: component)
        
        let viewController = ProfileHomeViewController()
        viewController.screenName = "profile"
        let interactor = ProfileHomeInteractor(
            presenter: viewController,
            dependency: component
        )
        interactor.listener = listener

        return ProfileHomeRouter(
            interactor: interactor,
            viewController: viewController,
            profilePasswordBuildable: profilePasswordBuildable,
            profileDeveloperBuildable: profileDveloperBuildable,
            profileOpensourceBuildable: profileOpensourceBuildable,
            profileBackupBuildable: profileBackupBuildable,
            profileRestoreBuildable: profileRestoreBuildable,
            designSystemBuildable: designSystemBuildable,
            bottomSheetBuildable: bottomSheetBuildable
        )
    }
}
