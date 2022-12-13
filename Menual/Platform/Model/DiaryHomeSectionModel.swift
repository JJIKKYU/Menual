//
//  DiaryHomeSectionModel.swift
//  Menual
//
//  Created by 정진균 on 2022/12/04.
//

import Foundation

public struct DiaryHomeFilteredSectionModel {
    var allCount: Int
    var diarySectionModelDic: [String: DiaryHomeSectionModel]
}

public struct DiaryHomeSectionModel {
    var sectionName: String
    var sectionIndex: Int
    var diaries: [DiaryModelRealm]
}
