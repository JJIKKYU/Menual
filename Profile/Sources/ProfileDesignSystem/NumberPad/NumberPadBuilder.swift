//
//  NumberPadBuilder.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import RIBs

protocol NumberPadDependency: Dependency {
    // TODO: Declare the set of dependencies required by this RIB, but cannot be
    // created by this RIB.
}

final class NumberPadComponent: Component<NumberPadDependency> {

    // TODO: Declare 'fileprivate' dependencies that are only used by this RIB.
}

// MARK: - Builder

protocol NumberPadBuildable: Buildable {
    func build(withListener listener: NumberPadListener) -> NumberPadRouting
}

final class NumberPadBuilder: Builder<NumberPadDependency>, NumberPadBuildable {

    override init(dependency: NumberPadDependency) {
        super.init(dependency: dependency)
    }

    func build(withListener listener: NumberPadListener) -> NumberPadRouting {
        let component = NumberPadComponent(dependency: dependency)
        let viewController = NumberPadViewController()
        let interactor = NumberPadInteractor(presenter: viewController)
        interactor.listener = listener
        return NumberPadRouter(interactor: interactor, viewController: viewController)
    }
}
