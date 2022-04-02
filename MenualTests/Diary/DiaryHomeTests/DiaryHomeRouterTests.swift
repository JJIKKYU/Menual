//
//  DiaryHomeRouterTests.swift
//  MenualTests
//
//  Created by 정진균 on 2022/04/02.
//

@testable import Menual
import RIBs
import XCTest

final class DiaryHomeRouterTests: XCTestCase {

    // TODO: declare other objects and mocks you need as private vars
    private var sut: DiaryHomeRouter!
    private var interactor: DiaryHomeInteractableMock!
    private var viewController: DiaryHomeViewControllableMock!
    private var profileHomeBuildable: ProfileHomeBuildableMock!
    private var diarySearchBuildable: DiarySearchBuildableMock!

    override func setUp() {
        super.setUp()

        interactor = DiaryHomeInteractableMock()
        viewController = DiaryHomeViewControllableMock()
        profileHomeBuildable = ProfileHomeBuildableMock()
        diarySearchBuildable = DiarySearchBuildableMock()
        
        sut = DiaryHomeRouter(interactor: interactor,
                              viewController: viewController,
                              profileHomeBuildable: profileHomeBuildable,
                              diarySearchBuildable: diarySearchBuildable)
    }

    // MARK: - Tests
    
    // 메인에서 마이페이지(ProfileHome) RIBs가 제대로 Attach되는지 테스트
    func testAttachProfileHome() {
        // given
        let router = ProfileHomeRoutingMock(
            interactable: Interactor(),
            viewControllable: ViewControllableMock())
        var assignedListner: ProfileHomeListener?
        
        profileHomeBuildable.buildHandler = { listener in
            assignedListner = listener
            return router
        }
        
        // when
        sut.attachMyPage()
        
        // then
        XCTAssertTrue(assignedListner === interactor)
        XCTAssertEqual(profileHomeBuildable.buildCallCount, 1)
    }
    
    // 메인에서 검색화면(DiarySearch) RIBs가 제대로 Attach되는지 테스트
    func testAttachDiarySearch() {
        // given
        let router = DiarySearchRoutingMock(
            interactable: Interactor(),
            viewControllable: ViewControllableMock()
        )
        var assignedListner: DiarySearchListener?
        
        diarySearchBuildable.buildHandler = { listener in
            assignedListner = listener
            return router
        }
        
        // when
        sut.attachDiarySearch()
        
        // then
        XCTAssertTrue(assignedListner === interactor)
        XCTAssertEqual(diarySearchBuildable.buildCallCount, 1)
    }
}
