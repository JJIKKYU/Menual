//
//  ProfileBackupInteractorTests.swift
//  Menual
//
//  Created by 정진균 on 2023/03/12.
//

@testable import ProfileBackup
import RIBs
import XCTest

final class ProfileBackupInteractorTests: XCTestCase {

    private var sut: ProfileBackupInteractor!
    private var presenter: ProfileBackupPresentableMock!
    private var dependency: ProfileBackupDependencyMock!
    private var interactorDependency: ProfileBackupInteractorDependencyMock!
    private var listener: ProfileBackupListenerMock!
    private var router: ProfileBackupRoutingMock!

    override func setUp() {
        super.setUp()
        
        presenter = ProfileBackupPresentableMock()
        dependency = ProfileBackupDependencyMock()
        listener = ProfileBackupListenerMock()
        interactorDependency = ProfileBackupInteractorDependencyMock()

        sut = ProfileBackupInteractor(
            presenter: presenter,
            dependency: interactorDependency
        )
    }

    // MARK: - Tests
    func testActivate() {
        // given
        
        // when
        sut.didBecomeActive()
        
        // then
        XCTAssertEqual(sut.isActive, true)
    }
}
