//
//  DiaryBottomSheetBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/04/24.
//

import RIBs
import RxSwift
import RxRelay

protocol DiaryBottomSheetDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var diaryRepository: DiaryRepository { get }
}

final class DiaryBottomSheetComponent: Component<DiaryBottomSheetDependency>, DiaryWritingDependency {
    var diaryRepository: DiaryRepository { dependency.diaryRepository }

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol DiaryBottomSheetBuildable: Buildable {
    func build(
        withListener listener: DiaryBottomSheetListener,
        bottomSheetType: MenualBottomSheetType,
        menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>?
    ) -> DiaryBottomSheetRouting
}

final class DiaryBottomSheetBuilder: Builder<DiaryBottomSheetDependency>, DiaryBottomSheetBuildable {

    override init(dependency: DiaryBottomSheetDependency) {
        super.init(dependency: dependency)
    }

    func build(
        withListener listener: DiaryBottomSheetListener,
        bottomSheetType: MenualBottomSheetType,
        menuComponentRelay: BehaviorRelay<MenualBottomSheetMenuComponentView.MenuComponent>?
    ) -> DiaryBottomSheetRouting {
        let component = DiaryBottomSheetComponent(dependency: dependency)
        
        let viewController = DiaryBottomSheetViewController()
        let diaryWritingBuildable = DiaryWritingBuilder(dependency: component)
        
        let interactor = DiaryBottomSheetInteractor(
            presenter: viewController,
            bottomSheetType: bottomSheetType,
            menuComponentRelay: menuComponentRelay
        )
        interactor.listener = listener

        return DiaryBottomSheetRouter(
            interactor: interactor,
            viewController: viewController,
            diaryWritingBuildable: diaryWritingBuildable
        )
    }
}
