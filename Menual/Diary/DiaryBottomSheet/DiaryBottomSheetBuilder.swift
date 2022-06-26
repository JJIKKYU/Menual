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
}

final class DiaryBottomSheetComponent: Component<DiaryBottomSheetDependency> {
    

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol DiaryBottomSheetBuildable: Buildable {
    func build(
        withListener listener: DiaryBottomSheetListener,
        weatherModelOb: BehaviorRelay<WeatherModel?>,
        placeModelOb: BehaviorRelay<PlaceModel?>,
        bottomSheetType: MenualBottomSheetType
    ) -> DiaryBottomSheetRouting
}

final class DiaryBottomSheetBuilder: Builder<DiaryBottomSheetDependency>, DiaryBottomSheetBuildable {

    override init(dependency: DiaryBottomSheetDependency) {
        super.init(dependency: dependency)
    }

    func build(
        withListener listener: DiaryBottomSheetListener,
        weatherModelOb: BehaviorRelay<WeatherModel?>,
        placeModelOb: BehaviorRelay<PlaceModel?>,
        bottomSheetType: MenualBottomSheetType
    ) -> DiaryBottomSheetRouting {
        let component = DiaryBottomSheetComponent(dependency: dependency)
        
        let viewController = DiaryBottomSheetViewController()
        let interactor = DiaryBottomSheetInteractor(
            presenter: viewController,
            weatherModelOb: weatherModelOb,
            placeModelOb: placeModelOb,
            bottomSheetType: bottomSheetType
        )
        interactor.listener = listener
        return DiaryBottomSheetRouter(interactor: interactor, viewController: viewController)
    }
}
