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

    // TODO: declare other objects and mocks you need as private vars

    override func setUp() {
        super.setUp()

        // TODO: instantiate objects and mocks
        self.presenter = DiaryHomePresentableMock()
        self.dependency = DiaryHomeDependencyMock()
        
        sut = DiaryHomeInteractor(presenter: self.presenter)
    }

    // MARK: - Tests

    func test_exampleObservable_callsRouterOrListener_exampleProtocol() {
        // given
        
        // when
        
        // then
    }
}
