//
//  DiarySearchInteractorTests.swift
//  MenualTests
//
//  Created by 정진균 on 2022/04/02.
//

@testable import Menual
import XCTest

final class DiarySearchInteractorTests: XCTestCase {

    private var sut: DiarySearchInteractor!
    private var presenter: DiarySearchPresentableMock!
    private var dependency: DiarySearchDependencyMock!
    private var listener: DiarySearchListenerMock!
    private var router: DiarySearchRoutingMock!

    // TODO: declare other objects and mocks you need as private vars

    override func setUp() {
        super.setUp()

        // TODO: instantiate objects and mocks
        self.presenter = DiarySearchPresentableMock()
        self.dependency = DiarySearchDependencyMock()
        self.listener = DiarySearchListenerMock()
        
        let interactor = DiarySearchInteractor(presenter: self.presenter)
        
        self.router = DiarySearchRoutingMock(
            interactable: interactor,
            viewControllable: ViewControllableMock()
        )
        
        interactor.router = self.router
        interactor.listener = self.listener
        sut = interactor
    }

    // MARK: - Tests

    func test_exampleObservable_callsRouterOrListener_exampleProtocol() {
        // given
        
        // when
        sut.pressedBackBtn()
        
        // thenq
        XCTAssertEqual(listener.diarySearchPressedBackBtnCallCount, 1)
    }
}
