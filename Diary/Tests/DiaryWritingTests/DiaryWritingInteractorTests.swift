//
//  DiaryWritingInteractorTests.swift
//  
//
//  Created by 정진균 on 2023/02/05.
//

import Foundation
import XCTest
import MenualEntity
import RxSwift
import RIBs
@testable import MenualRepositoryTestSupport
@testable import DiaryWriting

final class DiaryWritingInteractorTests: XCTestCase {
    
    private var sut: DiaryWritingInteractor!
    private var sutEditMode: DiaryWritingInteractor!
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
                                                diaryModel : nil,
                                                page: 0
        )
        sutEditMode = DiaryWritingInteractor(presenter: self.presenter,
                                             dependency: self.dependency,
                                             diaryModel: diaryModelRealm,
                                             page: 123
        )
        sut.listener = self.listener
    }
    
    // MARK: - Tests
    
    func testActivate() throws {
        // given

        // when
        sut.didBecomeActive()
        
        // then
        XCTAssertEqual(sut.diaryWritingMode, .writing)
    }
    
    func testActivateWithDiaryModel() {
        // given
        
        // when
        sutEditMode.didBecomeActive()
        
        // then
        XCTAssertEqual(sutEditMode.diaryWritingMode, .edit)
    }
    
    func testPressedBackBtn() {
        // given
        
        // when
        sut.pressedBackBtn(isOnlyDetach: false)
        
        // then
        XCTAssertEqual(listener?.diaryWritingPressedBackBtnCallCount, 1)
    }
    
    func testWriteDiary() {
        // given
        let diaryModelRealm = DiaryModelRealm(pageNum: 999,
                                              title: "testTitle",
                                              weather: nil,
                                              place: nil,
                                              desc: "testDesc",
                                              image: false,
                                              createdAt: Date(),
                                              lastMomentsDate: nil
        )

        // when
        sut.writeDiary(info: diaryModelRealm)
        
        // then
        XCTAssertEqual(diaryRepository.addDiaryCallCount, 1)
    }
    
    func testWriteDiaryWithTempSave() {
        // given
        let diaryModelRealm = DiaryModelRealm(pageNum: 999,
                                              title: "testTitle",
                                              weather: nil,
                                              place: nil,
                                              desc: "testDesc",
                                              image: false,
                                              createdAt: Date(),
                                              lastMomentsDate: nil
        )
        let tempSaveDiaryModelRealm = DiaryModelRealm(pageNum: 123,
                                                      title: "tempSaveTitle",
                                                      weather: nil,
                                                      place: nil,
                                                      desc: "tempSaveTestDesc",
                                                      image: false,
                                                      createdAt: Date(),
                                                      lastMomentsDate: nil
        )
        let tempSaveModelRealm = TempSaveModelRealm(uuid: UUID().uuidString,
                                                    diaryModel: tempSaveDiaryModelRealm,
                                                    createdAt: Date(),
                                                    isDeleted: false
        )
        
        // when
        sut.activate()
        sut.tempSaveDiaryModelRelay.accept(tempSaveModelRealm)
        sut.writeDiary(info: diaryModelRealm)
        
        // then
        XCTAssertEqual(diaryRepository.deleteTempSaveCallCount, 1)
        XCTAssertEqual(diaryRepository.deleteImageFromDocumentDirectoryCallCount, 1)
        XCTAssertEqual(diaryRepository.addDiaryCallCount, 1)
    }
    
    func testSaveTempSave() {
        // given
        let diaryModelRealm = DiaryModelRealm(pageNum: 999,
                                              title: "testTitle",
                                              weather: nil,
                                              place: nil,
                                              desc: "testDesc",
                                              image: false,
                                              createdAt: Date(),
                                              lastMomentsDate: nil
        )
        
        // when
        sut.saveTempSave(diaryModel: diaryModelRealm,
                         originalImageData: nil,
                         cropImageData: nil
        )
        
        // then
        XCTAssertEqual(diaryRepository.addTempSaveCallCount, 1)
    }
    
    func testTempSaveReset() {
        // given
        
        // when
        sut.activate()
        sut.tempSaveResetRelay.accept(true)
        
        // then
        XCTAssertEqual(presenter.resetDiaryCallCount, 1)
    }
    
    /// 정상적인 값이 들어갔을 경우
    func testUpdateDiary() {
        // given
        let diaryModelRealm = DiaryModelRealm(pageNum: 999,
                                              title: "testTitle",
                                              weather: nil,
                                              place: nil,
                                              desc: "testDesc",
                                              image: false,
                                              createdAt: Date(),
                                              lastMomentsDate: nil
        )
        let newDiaryModelRealm = DiaryModelRealm(pageNum: 1,
                                              title: "newTestTitle",
                                              weather: nil,
                                              place: nil,
                                              desc: "newTestDesc",
                                              image: false,
                                              createdAt: Date(),
                                              lastMomentsDate: nil
        )
        let exp = expectation(description: "testUpdateDiary")
        
        // when
        sut.activate()
        sut.diaryModelRelay.accept(diaryModelRealm)
        sut.updateDiary(info: newDiaryModelRealm, edittedImage: false)
        
        Observable.combineLatest(
            sut.imageSaveRelay,
            sut.updateDiaryModelRelay
        )
        .subscribe(onNext: { _, _ in
            exp.fulfill()
        })
        .disposed(by: sut.disposebag)
        
        
        wait(for: [exp], timeout: 1)
        
        // then
        XCTAssertEqual(diaryRepository.updateDiaryCallCount1, 1)
    }
    
    /// originalDiaryModel이 nil이어서 아무런 업데이트도 되지 않았을 경우
    func testUpdateDiaryIfNil() {
        // given
        let newDiaryModelRealm = DiaryModelRealm(pageNum: 1,
                                              title: "newTestTitle",
                                              weather: nil,
                                              place: nil,
                                              desc: "newTestDesc",
                                              image: false,
                                              createdAt: Date(),
                                              lastMomentsDate: nil
        )
        let exp = expectation(description: "testUpdateDiaryIfNil")
        
        // when
        sut.activate()
        sut.updateDiary(info: newDiaryModelRealm, edittedImage: false)
        
        Observable.combineLatest(
            sut.imageSaveRelay,
            sut.updateDiaryModelRelay
        )
        .subscribe(onNext: { _, _ in
            exp.fulfill()
        })
        .disposed(by: sut.disposebag)
        
        
        wait(for: [exp], timeout: 1)
        
        // then
        XCTAssertEqual(diaryRepository.updateDiaryCallCount1, 0)
    }
    
    func testSaveCropImage() {
        // given
        
        // when
        sut.saveCropImage(diaryUUID: UUID().uuidString, imageData: Data())
        
        // then
        XCTAssertEqual(diaryRepository.saveImageToDocumentDirectoryCallCount, 1)
    }
    
    func testsaveOriginalImage() {
        // given
        
        // when
        sut.saveOriginalImage(diaryUUID: UUID().uuidString, imageData: Data())
        
        // then
        XCTAssertEqual(diaryRepository.saveImageToDocumentDirectoryCallCount, 1)
    }
    
    func testsaveThumbImage() {
        // given
        
        // when
        sut.saveThumbImage(diaryUUID: UUID().uuidString, imageData: Data())
        
        // then
        XCTAssertEqual(diaryRepository.saveImageToDocumentDirectoryCallCount, 1)
    }
    
    func testDeleteAllImages() {
        // given
        
        // when
        sut.deleteAllImages(diaryUUID: UUID().uuidString)
        
        // then
        XCTAssertEqual(diaryRepository.deleteImageFromDocumentDirectoryCallCount, 1)
    }
    
    /// 초기화할 때 diaryModel이 들어갈 경우 edit모드로 변경되는지
    func testDiaryWritingMode() {
        // given
        let diaryModelRealm = DiaryModelRealm(pageNum: 999,
                                              title: "testTitle",
                                              weather: nil,
                                              place: nil,
                                              desc: "testDesc",
                                              image: false,
                                              createdAt: Date(),
                                              lastMomentsDate: nil
        )
        
        // when
        sut.activate()
        sut.diaryModelRelay.accept(diaryModelRealm)
        
        // then
        XCTAssertEqual(sut.diaryWritingMode, .edit)
        XCTAssertEqual(presenter.setDiaryEditModeCallCount, 1)
    }
}
