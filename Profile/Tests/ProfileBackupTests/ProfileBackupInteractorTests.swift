//
//  ProfileBackupInteractorTests.swift
//  Menual
//
//  Created by 정진균 on 2023/03/12.
//

@testable import ProfileBackup
import RIBs
import XCTest
import RealmSwift
import MenualUtil
import MenualEntity
import MenualRepositoryTestSupport

final class ProfileBackupInteractorTests: XCTestCase {

    private var sut: ProfileBackupInteractor!
    private var presenter: ProfileBackupPresentableMock!
    private var dependency: ProfileBackupInteractorDependencyMock!
    private var listener: ProfileBackupListenerMock!
    private var router: ProfileBackupRoutingMock!
    
    private var backupRestoreRepository: BackupRestoreRepositoryMock {
        dependency.backupRestoreRepository as! BackupRestoreRepositoryMock
    }

    override func setUp() {
        super.setUp()
        
        presenter = ProfileBackupPresentableMock()
        dependency = ProfileBackupInteractorDependencyMock()
        listener = ProfileBackupListenerMock()

        sut = ProfileBackupInteractor(
            presenter: presenter,
            dependency: dependency
        )
        sut.listener = listener
    }

    // MARK: - Tests
    
    /// BackupHistoryModelRealm DB 정보가 없으면, UI를 세팅하지 않음 (기본 UI로 세팅)
    func testActivate() {
        // given
        
        // when
        sut.activate()
        
        // then
        XCTAssertEqual(sut.isActive, true)
        XCTAssertEqual(presenter.configueBackupHistoryUICallCount, 0)
    }
    
    func testResignActive() {
        // given
        
        // when
        sut.willResignActive()
        sut.deactivate()
        
        // then
        XCTAssertEqual(sut.isActive, false)
    }
    
    /// BackupHistoryModelRealm DB 정보가 있으면, UI를 세팅하는지
    func testActivateIfBackupHistoryModelRealmExist() {
        // given
        let exp = expectation(description: "testActivateIfBackupHistoryModelRealmExist")

        guard let realm = Realm.safeInit() else { return }
        let backupHistoryModelRealm = BackupHistoryModelRealm(pageCount: 0,
                                                              diaryCount: 1,
                                                              createdAt: Date())
        realm.safeWrite {
            realm.add(backupHistoryModelRealm)
        }
        
        // when
        sut.activate()
        
        realm.objects(BackupHistoryModelRealm.self)
            .observe { [weak self] result in
                switch result {
                case .initial(_):
                    exp.fulfill()
                default:
                    break
                }
            }
        
        wait(for: [exp], timeout: 1)
        
        // then
        XCTAssertEqual(sut.isActive, true)
        XCTAssertEqual(presenter.configueBackupHistoryUICallCount, 1)
    }
    
    /// 백업이 가능한 상황인지 체크
    /// PassCondition : 다이어리가 하나 이상이면 Backup 가능
    func testCheckIsBackupEnabled_True() {
        // given
        guard let realm = Realm.safeInit() else { return }
        let diaryModelRealm = DiaryModelRealm(pageNum: 1,
                                              title: "testTitle",
                                              weather: nil,
                                              place: nil,
                                              desc: "testDesc",
                                              image: false,
                                              createdAt: Date()
        )
        realm.safeWrite {
            realm.add(diaryModelRealm)
        }
        
        // when
        sut.activate()
        let isEnabled = sut.checkIsBackupEnabled()
        
        // then
        XCTAssertEqual(isEnabled, true)
    }
    
    /// 백업이 가능한 상황인지 체크
    /// PassCondition : 다이어리가 하나도 없으면 Backup 불가능
    func testCheckIsBackupEnabled_False() {
        // given
        guard let realm = Realm.safeInit() else { return }
        realm.safeWrite {
            realm.delete(realm.objects(DiaryModelRealm.self))
        }
        
        
        // when
        sut.activate()
        let isEnabled = sut.checkIsBackupEnabled()
        
        // then
        XCTAssertEqual(isEnabled, false)
    }
    
    /// backBtn을 눌렀을때 부모에게 잘 전달되는지
    func testPressedBackBtn() {
        // given
        
        // when
        sut.didBecomeActive()
        sut.pressedBackBtn(isOnlyDetach: true)
        
        // then
        XCTAssertEqual(listener.pressedProfileBackupBackBtnCallCount, 1)
        XCTAssertEqual(listener.pressedBackBtnParameters?.isOnlyDetach, true)
    }
    
    /// backup History가 Repository를 통해 잘 생성 및 업데이트 되는지
    func testAddOrdUpdateBackupHistory() {
        // given
        
        // when
        sut.addOrUpdateBackupHistory()
        
        // then
        XCTAssertEqual(backupRestoreRepository.addOrUpdateBackupHistoryCallCount, 1)
    }
    
    /// 오늘 날짜 기준으로 Path를 잘 작성하는지 테스트
    func testTempZipPath() {
        // given
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let destTempPath = path + "/\(Date().toString())_Menual_Backup.zip"
        
        // when
        sut.activate()
        let tempPath = sut.tempZipPath()
        
        
        // then
        XCTAssertEqual(tempPath, destTempPath)
    }
    
    /// Zip Archive가 잘 진행 되는지
    func testSaveZip() {
        // given
        
        // when
        sut.saveZip()
        
        // then
        XCTAssertEqual(presenter.showShareSheetCallCount, 1)
    }
}
