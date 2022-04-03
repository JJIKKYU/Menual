//
//  DiaryHomeInteractorTests.swift
//  MenualTests
//
//  Created by 정진균 on 2022/04/02.
//

@testable import Menual
import XCTest

final class DiaryHomeInteractorTests: XCTestCase {

    private var sut: DiaryHomeInteractor!
    private var presenter: DiaryHomePresentableMock!
    private var dependency: DiaryHomeDependencyMock!
    private var listener: DiaryHomeListenerMock!
    private var router: DiaryHomeRoutingMock!

    // TODO: declare other objects and mocks you need as private vars

    override func setUp() {
        super.setUp()

        // TODO: instantiate objects and mocks
        self.presenter = DiaryHomePresentableMock()
        self.dependency = DiaryHomeDependencyMock()
        self.listener = DiaryHomeListenerMock()

        let interactor = DiaryHomeInteractor(presenter: self.presenter)

        self.router = DiaryHomeRoutingMock(
            interactable: interactor,
            viewControllable: ViewControllableMock()
        )
        
        interactor.router = self.router
        interactor.listener = self.listener
        sut = interactor
    }

    // MARK: - Tests
    func testPressedMyPageBtn() {
        // given
        
        // when
        sut.activate()
        sut.pressedMyPageBtn()
        sut.profileHomePressedBackBtn()
        
        // then
        XCTAssertEqual(router.attachMyPageCallCount, 1)
        XCTAssertEqual(router.detachMyPageCallCount, 1)
    }
    
    func testAttachDettachDiarySearch() {
        // given
        
        // when
        sut.activate()
        sut.pressedSearchBtn()
        sut.diarySearchPressedBackBtn()
        
        // then
        XCTAssertEqual(router.attachDiarySearchCallCount, 1)
        XCTAssertEqual(router.dettachDiarySearchCallCount, 1)
    }
    
    func testAttachDettachDiaryMoments() {
        // given
        
        // when
        sut.activate()
        sut.pressedMomentsMoreBtn()
        sut.pressedMomentsTitleBtn()
        sut.diaryMomentsPressedBackBtn()
        
        // then
        XCTAssertEqual(router.attachDiaryMomentsCallCount, 2)
        XCTAssertEqual(router.detachDiaryMomentsCallCount, 1)
    }
}
