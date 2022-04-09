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
    private var diaryMomentsBuildable: DiaryMomentsBuildableMock!
    private var diaryWritingBuildable: DiaryWritingBuildableMock!

    override func setUp() {
        super.setUp()

        interactor = DiaryHomeInteractableMock()
        viewController = DiaryHomeViewControllableMock()
        profileHomeBuildable = ProfileHomeBuildableMock()
        diarySearchBuildable = DiarySearchBuildableMock()
        diaryMomentsBuildable = DiaryMomentsBuildableMock()
        diaryWritingBuildable = DiaryWritingBuildableMock()
        
        sut = DiaryHomeRouter(interactor: interactor,
                              viewController: viewController,
                              profileHomeBuildable: profileHomeBuildable,
                              diarySearchBuildable: diarySearchBuildable,
                              diaryMomentsBuildable: diaryMomentsBuildable,
                              diaryWritingBuildable: diaryWritingBuildable
        )
    }

    // MARK: - Tests
    
    // 메인에서 마이페이지(ProfileHome) RIBs가 제대로 Attach되는지 테스트
    func testAttachProfileHome() {
        // given
        let router = ProfileHomeRoutingMock(
            interactable: Interactor(),
            viewControllable: ViewControllableMock())
        var assignedListener: ProfileHomeListener?
        
        profileHomeBuildable.buildHandler = { listener in
            assignedListener = listener
            return router
        }
        
        // when
        sut.attachMyPage()
        
        // then
        XCTAssertTrue(assignedListener === interactor)
        XCTAssertEqual(profileHomeBuildable.buildCallCount, 1)
    }
    
    // 메인에서 검색화면(DiarySearch) RIBs가 제대로 Attach되는지 테스트
    func testAttachDiarySearch() {
        // given
        let router = DiarySearchRoutingMock(
            interactable: Interactor(),
            viewControllable: ViewControllableMock()
        )
        var assignedListener: DiarySearchListener?
        
        diarySearchBuildable.buildHandler = { listener in
            assignedListener = listener
            return router
        }
        
        // when
        sut.attachDiarySearch()
        
        // then
        XCTAssertTrue(assignedListener === interactor)
        XCTAssertEqual(diarySearchBuildable.buildCallCount, 1)
    }
    
    // 메인에서 Moments(DiaryMoments) RIBs가 제대로 Attach되는지 테스트
    func testAttachDiaryMoments() {
        // given
        let router = DiaryMomentsRoutingMock(
            interactable: Interactor(),
            viewControllable: ViewControllableMock()
        )
        var assignedListener: DiaryMomentsListener?
        
        diaryMomentsBuildable.buildHandler = { listener in
            assignedListener = listener
            return router
        }
        
        // when
        sut.attachDiaryMoments()
        
        // then
        XCTAssertTrue(assignedListener === interactor)
        XCTAssertEqual(diaryMomentsBuildable.buildCallCount, 1)
    }
    
    // 메인에서 글쓰기 페이지(DiaryWriting) RIBs가 제대로 Attach되는지 테스트
    func testAttachDiaryWriting() {
        // given
        let router = DiaryWritingRoutingMock(
            interactable: Interactor(),
            viewControllable: ViewControllableMock()
        )
        var assignedListener: DiaryWritingListener?
        
        diaryWritingBuildable.buildHandler = { listener in
            assignedListener = listener
            return router
        }
        
        // when
        sut.attachDiaryWriting()
        
        // then
        XCTAssertTrue(assignedListener === interactor)
        XCTAssertEqual(diaryWritingBuildable.buildCallCount, 1)
    }
}
