//
//  DiaryWritingBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/01/09.
//

import RIBs
import RxRelay
import MenualEntity
import MenualRepository
import DiaryTempSave

public protocol DiaryWritingDependency: Dependency {
    var diaryRepository: DiaryRepository { get }
}

public final class DiaryWritingComponent: Component<DiaryWritingDependency>, DiaryWritingInteractorDependency, DiaryTempSaveDependency {
    
    var filteredWeatherArrRelay: BehaviorRelay<[Weather]>?
    var filteredPlaceArrRelay: BehaviorRelay<[Place]>?
    var filteredDiaryCountRelay: BehaviorRelay<Int>?
    public var diaryRepository: DiaryRepository { dependency.diaryRepository }

}

// MARK: - Builder

public protocol DiaryWritingBuildable: Buildable {
    func build(
        withListener listener: DiaryWritingListener,
        diaryModel: DiaryModelRealm?,
        page: Int
    ) -> DiaryWritingRouting
}

public final class DiaryWritingBuilder: Builder<DiaryWritingDependency>, DiaryWritingBuildable {

    public override init(dependency: DiaryWritingDependency) {
        super.init(dependency: dependency)
    }

    public func build(
        withListener listener: DiaryWritingListener,
        diaryModel: DiaryModelRealm?,
        page: Int
    ) -> DiaryWritingRouting {
        let component = DiaryWritingComponent(dependency: dependency)

        let diaryTempSaveBuildable = DiaryTempSaveBuilder(dependency: component)
        
        let viewController = DiaryWritingViewController()
        viewController.screenName = "writing"
        let interactor = DiaryWritingInteractor(
            presenter: viewController,
            dependency: component,
            diaryModel: diaryModel,
            page: page
        )
        interactor.listener = listener
        return DiaryWritingRouter(
            interactor: interactor,
            viewController: viewController,
            diaryTempSaveBuildable: diaryTempSaveBuildable
        )
    }
}
