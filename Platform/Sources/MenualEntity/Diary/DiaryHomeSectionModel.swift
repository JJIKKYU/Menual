//
//  DiaryHomeSectionModel.swift
//  Menual
//
//  Created by 정진균 on 2022/12/04.
//

import Foundation

public struct DiaryHomeFilteredSectionModel {
    public var allCount: Int
    public var diarySectionModelDic: [String: DiaryHomeSectionModel]

    public init(allCount: Int, diarySectionModelDic: [String : DiaryHomeSectionModel]) {
        self.allCount = allCount
        self.diarySectionModelDic = diarySectionModelDic
    }
}

public struct DiaryHomeSectionModel {
    public var sectionName: String
    public var sectionIndex: Int
    public var diaries: [DiaryModelRealm]
    
    public init(sectionName: String, sectionIndex: Int, diaries: [DiaryModelRealm]) {
        self.sectionName = sectionName
        self.sectionIndex = sectionIndex
        self.diaries = diaries
    }
}
