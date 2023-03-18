//
//  BackupRestoreRepositoryTests.swift
//  
//
//  Created by 정진균 on 2023/03/18.
//

import Foundation
import XCTest
import MenualEntity
import RxSwift
import RealmSwift
@testable import MenualRepositoryTestSupport
@testable import MenualRepository


final class BackupRestoreRepositoryTests: XCTestCase {
    
    private var sut: BackupRestoreRepositoryImp!

    override func setUp() {
        sut = BackupRestoreRepositoryImp()
    }
    
    /// backup이 잘 진행되고 있는지 테스트
    func testBackup() {
        guard let realm = Realm.safeInit() else { return }
        // given
        var backupDataDic: [String: Data] = [:]
        var backupDataArr: [Data] = []
        
        // DiaryModelRealm 추가
        var diaryModelRealmArr: [DiaryModelRealm] = []
        for i in 0..<5 {
            let model = DiaryModelRealm(pageNum: i,
                            title: "test_\(i)",
                            weather: WeatherModelRealm(
                                weather: .cloud,
                                detailText: "cloud_\(i)"
                            ),
                            place: PlaceModelRealm(
                                place: .bus,
                                detailText: "bus_\(i)"
                            ),
                            desc: "desc_\(i)",
                            image: false,
                            createdAt: Date()
                           )
            diaryModelRealmArr.append(model)
        }
        
        // Moments 추가
        var momentsModelRealmArr: [MomentsRealm] = []
        let momentsModelRealm = MomentsRealm(
            lastUpdatedDate: Date(),
            onboardingClearDate: Date(),
            onboardingIsClear: true,
            items: [
                MomentsItemRealm(order: 0,
                                 title: "title_0",
                                 uuid: "testuuid_0",
                                 icon: "icon_0",
                                 diaryUUID: "diaryuuid_0",
                                 userChecked: false,
                                 createdAt: Date()
                                )
            ]
        )
        momentsModelRealmArr.append(momentsModelRealm)
        
        // TempSave 추가
        var tempSaveModelRealmArr: [TempSaveModelRealm] = []
        let tempSaveModelRealm = TempSaveModelRealm(
            uuid: "testuuid_0",
            diaryModel: DiaryModelRealm(
                pageNum: 0,
                title: "testtitle_0",
                weather: nil,
                place: nil,
                desc: "testdesc_0",
                image: false,
                createdAt: Date()
            ),
            createdAt: Date(),
            isDeleted: false
        )
        tempSaveModelRealmArr.append(tempSaveModelRealm)
        
        // DiarySearch 추가
        var diarySearchModelRealmArr: [DiarySearchModelRealm] = []
        let diarySearchModelRealm = DiarySearchModelRealm(
            diaryUuid: "testuuid_0",
            diary: nil,
            createdAt: Date(),
            isDeleted: false
        )
        diarySearchModelRealmArr.append(diarySearchModelRealm)
        
        // Password 추가
        var passwordModelRealmArr: [PasswordModelRealm] = []
        let passwordModelRealm = PasswordModelRealm(
            password: 1111,
            isEnabled: true
        )
        passwordModelRealmArr.append(passwordModelRealm)
        
        if let diaryData = sut.makeBackupData(of: DiaryModelRealm.self) {
            backupDataDic["diary"] = diaryData
            backupDataArr.append(diaryData)
        }
        if let momentsData = sut.makeBackupData(of: MomentsRealm.self) {
            backupDataDic["moments"] = momentsData
            backupDataArr.append(momentsData)
        }
        if let tempSaveData = sut.makeBackupData(of: TempSaveModelRealm.self) {
            backupDataDic["tempSave"] = tempSaveData
            backupDataArr.append(tempSaveData)
        }
        if let diarySearchData = sut.makeBackupData(of: DiarySearchModelRealm.self) {
            backupDataDic["diarySearch"] = diarySearchData
            backupDataArr.append(diarySearchData)
        }
        if let passwordData = sut.makeBackupData(of: PasswordModelRealm.self) {
            backupDataDic["password"] = passwordData
            backupDataArr.append(passwordData)
        }
        
        realm.safeWrite {
            realm.delete(realm.objects(DiaryModelRealm.self))
            realm.delete(realm.objects(MomentsRealm.self))
            realm.delete(realm.objects(TempSaveModelRealm.self))
            realm.delete(realm.objects(DiarySearchModelRealm.self))
            realm.delete(realm.objects(PasswordModelRealm.self))

            realm.add(diaryModelRealmArr)
            realm.add(momentsModelRealmArr)
            realm.add(tempSaveModelRealmArr)
            realm.add(diarySearchModelRealmArr)
            realm.add(passwordModelRealmArr)
        }
        
        // when
        let testTargetDataDic = sut.backUp()
        
        XCTAssertEqual(
            testTargetDataDic["moments"]?.count,
            backupDataDic["moments"]?.count
        )

        XCTAssertEqual(
            testTargetDataDic["diary"]?.count,
            backupDataDic["diary"]?.count
        )
        
        XCTAssertEqual(
            testTargetDataDic["diarySearch"]?.count,
            backupDataDic["diarySearch"]?.count
        )
        
        XCTAssertEqual(
            testTargetDataDic["tempSave"]?.count,
            backupDataDic["tempSave"]?.count
        )
        
        XCTAssertEqual(
            testTargetDataDic["password"]?.count,
            backupDataDic["password"]?.count
        )
    }
    
    /// 백업 파일이 정상적으로 저장되는지 확인
    /// - 파일이 있거나 없거나, 기본적으로 모든 백업파일은 1:1로 생성되므로, 생성이 되지 않으면 fail
    func testAlreadyBackupFileExist() {
        // given
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let checkFileNameArr: [String] = [
            "diary",
            "moments",
            "tempSave",
            "diarySearch",
            "password"
        ]
        
        // when
        _ = sut.backUp()
        
        // then
        for name in checkFileNameArr {
            let fileURL = documentsURL.appendingPathComponent("\(name).json")
            var exist: Bool = false
            if fileManager.fileExists(atPath: fileURL.path) {
                exist = true
            }
            XCTAssertEqual(exist, true)
        }
    }
}
