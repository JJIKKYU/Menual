//
//  MigrationState.swift
//
//
//  Created by 정진균 on 11/11/23.
//

import Foundation

public enum MigrationState {
    case idle
    case notNeeded
    case inProgress
    case completed
}

public enum MigrationType: String {
    // 23.11.11 이미지 다중 선택 마이그레이션
    case imageMultiSelect = "ImageMultiSelect"
}
