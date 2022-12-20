//
//  DiaryTempSaveBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/05/15.
//

import RIBs
import RxRelay

protocol DiaryTempSaveDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
    var diaryRepository: DiaryRepository { get }
}

final class DiaryTempSaveComponent: Component<DiaryTempSaveDependency>, DiaryTempSaveDependency {
    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
    var diaryRepository: DiaryRepository { dependency.diaryRepository }
}

// MARK: - Builder

protocol DiaryTempSaveBuildable: Buildable {
    func build(
        withListener listener: DiaryTempSaveListener,
        tempSaveDiaryModelRelay: BehaviorRelay<TempSaveModelRealm?>,
        tempSaveResetRelay: BehaviorRelay<Bool>
    ) -> DiaryTempSaveRouting
}

final class DiaryTempSaveBuilder: Builder<DiaryTempSaveDependency>, DiaryTempSaveBuildable {

    override init(dependency: DiaryTempSaveDependency) {
        super.init(dependency: dependency)
    }

    func build(
        withListener listener: DiaryTempSaveListener,
        tempSaveDiaryModelRelay: BehaviorRelay<TempSaveModelRealm?>,
        tempSaveResetRelay: BehaviorRelay<Bool>
    ) -> DiaryTempSaveRouting {

        let component = DiaryTempSaveComponent(dependency: dependency)
        let viewController = DiaryTempSaveViewController()
        viewController.screenName = "tempSave"
        let interactor = DiaryTempSaveInteractor(
            presenter: viewController,
            dependency: component,
            tempSaveDiaryModelRelay: tempSaveDiaryModelRelay,
            tempSaveResetRelay: tempSaveResetRelay
        )
        interactor.listener = listener
        return DiaryTempSaveRouter(interactor: interactor, viewController: viewController)
    }
}
