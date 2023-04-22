//
//  DiarySearchBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/03/27.
//

import RIBs
import MenualRepository
import DiaryDetail

public protocol DiarySearchDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var diaryRepository: DiaryRepository { get }
    var appstoreReviewRepository: AppstoreReviewRepository { get }
}

public final class DiarySearchComponent: Component<DiarySearchDependency>, DiaryDetailDependency, DiarySearchInteractorDependency
{
    public var diaryRepository: DiaryRepository { dependency.diaryRepository }
    public var appstoreReviewRepository: AppstoreReviewRepository { dependency.appstoreReviewRepository }

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

public protocol DiarySearchBuildable: Buildable {
    func build(withListener listener: DiarySearchListener) -> DiarySearchRouting
}

public final class DiarySearchBuilder: Builder<DiarySearchDependency>, DiarySearchBuildable {

    public override init(dependency: DiarySearchDependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: DiarySearchListener) -> DiarySearchRouting {
        let component = DiarySearchComponent(dependency: dependency)
        let viewController = DiarySearchViewController()
        viewController.screenName = "search"
        let interactor = DiarySearchInteractor(
            presenter: viewController,
            dependency: component
        )
        
        let diaryDetailBuildable = DiaryDetailBuilder(dependency: component)
        
        interactor.listener = listener
        return DiarySearchRouter(
            interactor: interactor,
            viewController: viewController,
            diaryDetailBuildable: diaryDetailBuildable)
    }
}
