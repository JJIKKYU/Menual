//
//  DiarySearchRouterTests.swift
//  MenualTests
//
//  Created by 정진균 on 2022/04/02.
//

@testable import Menual
import XCTest
import RIBs

final class DiarySearchRouterTests: XCTestCase {

    private var sut: DiarySearchRouter!
    private var interactor: DiarySearchInteractableMock!
    private var viewController: DiarySearchViewControllerMock!
    private var diarySearchBuildable: DiarySearchBuildableMock!

    // TODO: declare other objects and mocks you need as private vars

    override func setUp() {
        super.setUp()

        interactor = DiarySearchInteractableMock()
        viewController = DiarySearchViewControllerMock()
        
        sut = DiarySearchRouter(interactor: interactor,
                                viewController: viewController)
    }

    // MARK: - Tests

    func test_routeToExample_invokesToExampleResult() {
        // given
//        let router = DiarySearchRoutingMock(
//            interactable: Interactor(),
//            viewControllable: ViewControllableMock()
//        )
//        var assignedListener: DiarySearchListener?
//
//        diarySearchBuildable.buildHandler = { listener in
//            assignedListener = listener
//            return router
//        }
        
        // when
        
        
        // then
    }
}
