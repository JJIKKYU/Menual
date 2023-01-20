//
//  DiarySearchBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/03/27.
//

import RIBs
import MenualRepository

protocol DiarySearchDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var diaryRepository: DiaryRepository { get }
}

final class DiarySearchComponent: Component<DiarySearchDependency>, DiaryDetailDependency, DiarySearchInteractorDependency
{
    var diaryRepository: DiaryRepository { dependency.diaryRepository }

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol DiarySearchBuildable: Buildable {
    func build(withListener listener: DiarySearchListener) -> DiarySearchRouting
}

final class DiarySearchBuilder: Builder<DiarySearchDependency>, DiarySearchBuildable {

    override init(dependency: DiarySearchDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: DiarySearchListener) -> DiarySearchRouting {
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
