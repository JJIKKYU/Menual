//
//  ProfileRestoreConfirmInteractorTests.swift
//  
//
//  Created by 정진균 on 2023/03/12.
//

@testable import ProfileRestoreConfirm
import RIBs
import XCTest
import RxSwift
import RealmSwift
import MenualUtil
import MenualEntity
import MenualRepositoryTestSupport

final class ProfileRestoreConfirmInteractorTests: XCTestCase {
    
    private var sut: ProfileRestoreConfirmInteractor!
    private var presenter: ProfileRestoreConfirmPresentableMock!
    private var dependency: ProfileRestoreConfirmInteractorDependencyMock!
    private var listener: ProfileRestoreConfirmListenerMock!
    private var router: ProfileRestoreConfirmRoutingMock!
    private let disposeBag = DisposeBag()
    
    private var backupRestoreRepository: BackupRestoreRepositoryMock {
        dependency.backupRestoreRepository as! BackupRestoreRepositoryMock
    }
    
    private var destFileName: String = ""
    private var destFiilURL: URL?

    override func setUp() {
        super.setUp()
        
        setLocalZipFile_8Diary()
        
        presenter = ProfileRestoreConfirmPresentableMock()
        dependency = ProfileRestoreConfirmInteractorDependencyMock()
        listener = ProfileRestoreConfirmListenerMock()
        
        sut = ProfileRestoreConfirmInteractor(
            presenter: presenter,
            dependency: dependency,
            fileURL: destFiilURL
        )
        sut.listener = listener
    }

    /// 8개의 메뉴얼이 세팅되어 있는 ZipFile 세팅
    func setLocalZipFile_8Diary() {
        if let url = Bundle.module.url(forResource: "MenualBackupTestFile_8Diary", withExtension: "zip") {
            destFiilURL = url
            destFileName = "MenualBackupTestFile_8Diary.zip"
            // Do something with the file
        } else {
            destFiilURL = nil
        }
    }
    
    // MARK: - Tests

    /// ProfileRestoreConfirm Interactor가 활성화 될 때 최초에 Zip 파일을 제대로 확인하는 지 테스트
    func testActivate() {
        // given
        let exp = expectation(description: "testActivate")
        var testIsRestoreMenualFile: Bool = false
        
        // when
        sut.activate()
        sut.menualRestoreFileRelay
            .subscribe(onNext: { [weak self] isRestoreMenualFile in
                guard let self = self,
                      let isRestoreMenualFile = isRestoreMenualFile
                else { return }

                switch isRestoreMenualFile {
                case true:
                    testIsRestoreMenualFile = isRestoreMenualFile
                    exp.fulfill()
                case false:
                    testIsRestoreMenualFile = isRestoreMenualFile
                    exp.fulfill()
                    
                }
            })
            .disposed(by: disposeBag)
        
        wait(for: [exp], timeout: 1)
        
        // then
        XCTAssertEqual(sut.fileName, destFiilURL?.lastPathComponent)
        XCTAssertEqual(presenter.fileNameAndDateSetUICallCount, 1)
        XCTAssertEqual(testIsRestoreMenualFile, true)
    }
    
    func testWillResignActive() {
        // given
        
        // when
        sut.activate()
        sut.willResignActive()
        sut.deactivate()
        
        // then
        XCTAssertEqual(sut.isActive, false)
    }
    
    /// jsonParsing이 제대로 진행되는지 체크
    ///  - Zip파일이 정상적인 메뉴얼일 경우
    func testParseJson() {
        // given
        var createdAt: String = ""
        if let destFiilURL = destFiilURL {
            createdAt = sut.getFileCreatedAt(url: destFiilURL) ?? ""
        }

        var destRestoreFile = RestoreFile(
            fileName: self.destFileName,
            createdDate: createdAt,
            isVaildMenualRestoreFile: true
        )
        
        // diary.json이 의도한대로 잘 변환되는지
        if let diaryJsonURL = Bundle.module.url(forResource: "diary", withExtension: "json") {
            if let diaryJsonData = try? Data(contentsOf: diaryJsonURL) {
                destRestoreFile.diaryData = diaryJsonData
            }
        }
        
        // diarySearch.json이 의도한대로 잘 변환되는지
        if let diarySearchURL = Bundle.module.url(forResource: "diarySearch", withExtension: "json") {
            if let diarySearchData = try? Data(contentsOf: diarySearchURL) {
                destRestoreFile.diarySearchData = diarySearchData
            }
        }
        
        // moments.json이 의도한대로 잘 변환되는지
        if let momentsURL = Bundle.module.url(forResource: "moments", withExtension: "json") {
            if let momentsData = try? Data(contentsOf: momentsURL) {
                destRestoreFile.momentsData = momentsData
            }
        }
        
        // password.json이 의도한대로 잘 변환되는지
        if let passwordURL = Bundle.module.url(forResource: "password", withExtension: "json") {
            if let passwordData = try? Data(contentsOf: passwordURL) {
                destRestoreFile.passwordData = passwordData
            }
        }
        
        // tempSave.json이 의도한대로 잘 변환되는지
        if let tempSaveURL = Bundle.module.url(forResource: "tempSave", withExtension: "json") {
            if let tempSaveData = try? Data(contentsOf: tempSaveURL) {
                destRestoreFile.tempSaveData = tempSaveData
            }
        }
        
        // when
        sut.activate()
        let parseJsonRestoreFile = sut.parseJsonFile()
        
        // then
        XCTAssertEqual(parseJsonRestoreFile?.fileName, destRestoreFile.fileName)
        XCTAssertEqual(parseJsonRestoreFile?.createdDate, destRestoreFile.createdDate)
        XCTAssertEqual(parseJsonRestoreFile?.isVaildMenualRestoreFile, destRestoreFile.isVaildMenualRestoreFile)
        
        // json
        XCTAssertEqual(parseJsonRestoreFile?.diaryData, destRestoreFile.diaryData)
        XCTAssertEqual(parseJsonRestoreFile?.diarySearchData, destRestoreFile.diarySearchData)
        XCTAssertEqual(parseJsonRestoreFile?.momentsData, destRestoreFile.momentsData)
        XCTAssertEqual(parseJsonRestoreFile?.passwordData, destRestoreFile.passwordData)
        XCTAssertEqual(parseJsonRestoreFile?.tempSaveData, destRestoreFile.tempSaveData)
    }
    
    /// restoreBtn을 유저가 눌렀을 때, Restore 과정이 시나리오대로 진행되는지 확인
    func testRestore() {
        // given
        let exp = expectation(description: "testRestore")
        
        // when
        sut.activate()
        
        // 파일 압축이 정상적으로 끝나고, 눌러야 하므로 subscribe 후에 시작
        sut.menualRestoreFileRelay
            .subscribe(onNext: { [weak self] isRestoreMenualFile in
                guard let isRestoreMenualFile = isRestoreMenualFile
                else { return }

                switch isRestoreMenualFile {
                case true:
                    self?.sut.pressedRestoreBtn()
                    exp.fulfill()
                case false:
                    exp.fulfill()
                    
                }
            })
            .disposed(by: disposeBag)
        
        wait(for: [exp], timeout: 1)
        
        // then
        XCTAssertEqual(backupRestoreRepository.restoreWithJsonCallCount, 1)
        XCTAssertEqual(backupRestoreRepository.clearCacheDirecotryCallCount, 1)
        XCTAssertEqual(sut.menualRestoreProgressRelay.value, 1)
    }
    
    /// 최초 설치 상태에서 복원했을 경우
    func testRestore_최초설치상태() {
        
    }
    
    /// 온보딩 중 글 작성을 하나도 안한 상태
    func testRestore_온보딩중글작성을하나도안한상태() {
        
    }
    
    /// 온보딩 중 글 작성을 하나 이상이라도 한 상태
    func testRestore_온보딩중에글작성을한상태() {
        
    }
    
    /// 온보딩이 끝난 첫 날 상태
    func testRestore_온보딩이끝난첫날상태() {
        
    }
    
    /// Moments가 하나도 없는 상태
    func testRestore_Moments가하나도없는상태() {
        
    }
    
    /// Moments가 하나라도 있는 상태
    func testRestore_Moments가있는상태() {
        
    }
}
