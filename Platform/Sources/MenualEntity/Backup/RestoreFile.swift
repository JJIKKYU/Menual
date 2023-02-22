//
//  RestoreFile.swift
//  
//
//  Created by 정진균 on 2023/02/22.
//

import Foundation

public struct RestoreFile {
    /// 복원하고자 하는 파일의 이름
    public var fileName: String
    /// 복원하고자 하는 파일의 생성 날짜
    public var createdDate: String
    /// 복원하고자 하는 파일이 메뉴얼 복원 파일인지 체크
    public var isVaildMenualRestoreFile: Bool

    public var diaryJson: Data?
    public var diarySearchJson: Data?
    public var momentsJson: Data?
    public var passwordJson: Data?
    public var tempSaveJson: Data?
    public var imageDataArr: [Data]?
    
    public init(fileName: String, createdDate: String, isVaildMenualRestoreFile: Bool, diaryJson: Data? = nil, diarySearchJson: Data? = nil, momentsJson: Data? = nil, passwordJson: Data? = nil, tempSaveJson: Data? = nil, imageDataArr: [Data]? = nil) {
        self.fileName = fileName
        self.createdDate = createdDate
        self.isVaildMenualRestoreFile = isVaildMenualRestoreFile
        self.diaryJson = diaryJson
        self.diarySearchJson = diarySearchJson
        self.momentsJson = momentsJson
        self.passwordJson = passwordJson
        self.tempSaveJson = tempSaveJson
        self.imageDataArr = imageDataArr
    }
}
