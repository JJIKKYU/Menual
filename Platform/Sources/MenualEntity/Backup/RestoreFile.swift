//
//  RestoreFile.swift
//  
//
//  Created by 정진균 on 2023/02/22.
//

import Foundation
import Realm
import RealmSwift

public struct RestoreFile {
    /// 복원하고자 하는 파일의 이름
    public var fileName: String
    /// 복원하고자 하는 파일의 생성 날짜
    public var createdDate: String
    /// 복원하고자 하는 파일이 메뉴얼 복원 파일인지 체크
    public var isVaildMenualRestoreFile: Bool

    public var diaryData: Data?
    public var diarySearchData: Data?
    public var momentsData: Data?
    public var passwordData: Data?
    public var tempSaveData: Data?
    public var imageDataArr: [ImageFile] = []
    public var reviewData: Data?
    
    public init(fileName: String, createdDate: String, isVaildMenualRestoreFile: Bool) {
        self.fileName = fileName
        self.createdDate = createdDate
        self.isVaildMenualRestoreFile = isVaildMenualRestoreFile
    }
}

public struct ImageFile {
    public var fileName: String
    public var data: Data
    public var diaryUUID: String

    public init(fileName: String, data: Data, diaryUUID: String) {
        self.fileName = fileName
        self.data = data
        self.diaryUUID = diaryUUID
    }
}

/// 최종적으로 백업/복원 해야하는 파일 리스트
/// Realm 파일이 추가되면 항상 추가해야하는 enum
public enum RestoreFileType: String {
    case diary = "diary.json"
    case diarySearch = "diarySearch.json"
    case moments = "moments.json"
    case password = "password.json"
    case tempSave = "tempSave.json"
    case review = "review.json"
}
