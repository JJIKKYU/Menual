//
//  ProfilePasswordBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import RIBs
import MenualRepository

public protocol ProfilePasswordDependency: Dependency {
    var diaryRepository: DiaryRepository { get }
}

public final class ProfilePasswordComponent: Component<ProfilePasswordDependency>, ProfilePasswordInteractorDependency{
    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
    var diaryRepository: DiaryRepository { dependency.diaryRepository }
}

// MARK: - Builder

public protocol ProfilePasswordBuildable: Buildable {
    func build(
        withListener listener: ProfilePasswordListener,
        isMainScreen: Bool,
        isPasswordChange: Bool,
        isPaswwordDisabled: Bool
    ) -> ProfilePasswordRouting
}

public final class ProfilePasswordBuilder: Builder<ProfilePasswordDependency>, ProfilePasswordBuildable {

    public override init(dependency: ProfilePasswordDependency) {
        super.init(dependency: dependency)
    }

    public func build(
        withListener listener: ProfilePasswordListener,
        isMainScreen: Bool,
        isPasswordChange: Bool,
        isPaswwordDisabled: Bool
    ) -> ProfilePasswordRouting {
        let component = ProfilePasswordComponent(dependency: dependency)
        let viewController = ProfilePasswordViewController()
        let interactor = ProfilePasswordInteractor(
            presenter: viewController,
            dependency: component,
            isMainScreen: isMainScreen,
            isPasswordChange: isPasswordChange,
            isPaswwordDisabled: isPaswwordDisabled
        )
        interactor.listener = listener
        return ProfilePasswordRouter(interactor: interactor, viewController: viewController)
    }
}
