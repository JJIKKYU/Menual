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
        
        if let diaryData = sut.makeBackupData(of: DiaryModelRealm.self) {
            backupDataDic["diary"] = diaryData
        }
        
        realm.safeWrite {
            realm.delete(realm.objects(DiaryModelRealm.self))
            realm.add(diaryModelRealmArr)
        }
        
        // when
        let dataArr = sut.backUp()
        
        // then
        print("dataArr = \(dataArr)")
        print("backupDataDic = \(backupDataDic)")
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
        // 체크 된 순서대로 Bool값이 담김
        var checkFileNameResultArr: [Bool] = []

        
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
