//
//  DiaryWritingInteractorTests.swift
//  
//
//  Created by 정진균 on 2023/02/05.
//

import Foundation
import XCTest
import MenualEntity
import RIBs
@testable import MenualRepositoryTestSupport
@testable import DiaryWriting

final class DiaryWritingInteractorTests: XCTestCase {
    
    private var sut: DiaryWritingInteractor!
    private var presenter: DiaryWritingPresentableMock!
    private var dependency: DiaryWritingDependencyMock!
    private var listener: DiaryWritingListenerMock!
    private var router: DiaryWritingRoutingMock!
    
    private var diaryRepository: DiaryRepositoryMock {
        dependency.diaryRepository as! DiaryRepositoryMock
    }
    
    override func setUp() {
        super.setUp()
        
        self.presenter = DiaryWritingPresentableMock()
        self.dependency = DiaryWritingDependencyMock()
        self.listener = DiaryWritingListenerMock()
        let diaryModelRealm = DiaryModelRealm(pageNum: 999,
                                              title: "test",
                                              weather: WeatherModelRealm(weather: .cloud, detailText: "textCloud"),
                                              place: PlaceModelRealm(place: .bus, detailText: "textBus"),
                                              desc: "testDesc",
                                              image: false,
                                              createdAt: Date()
        )
        
        sut = DiaryWritingInteractor(presenter: self.presenter,
                                                dependency: self.dependency,
                                                diaryModel : diaryModelRealm,
                                                page: 999
        )
        sut.listener = self.listener
    }
    
    // MARK: - Tests
    
    func testActivate() throws {
        // given

        // when
        sut.didBecomeActive()
        
        // then
        XCTAssertEqual(presenter.listener?.page, 999)
    }
}
