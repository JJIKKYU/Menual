//
//  ProfileHomeMenuModel.swift
//  Menual
//
//  Created by 정진균 on 2023/07/29.
//

import Foundation

// MARK: - ProfileHomeCellType

public enum ProfileHomeCellType {
    case toggle
    case toggleWithDescription
    case arrow
}

// MARK: - ProfileHomeSection

public enum ProfileHomeSection: Int {
    case setting1 = 0
    case setting2 = 1
    case devMode
}

// MARK: - ProfileHomeMenuType

public enum ProfileHomeMenuType {
    case setting1(ProfileHomeSetting1)
    case setting2(ProfileHomeSetting2)
    case devMode(ProfileHomeDevMode)
}

public enum ProfileHomeSetting1: String {
    case guide
    case password
    case passwordChange
}

public enum ProfileHomeSetting2: String {
    case backup
    case restore
    case mail
    case openSource
}

public enum ProfileHomeDevMode: String {
    case tools
    case designSystem
    case review
    case alarm
}

// MARK: - ProfileHomeMenuModel

public struct ProfileHomeMenuModel {
    public let section: ProfileHomeSection
    public let cellType: ProfileHomeCellType
    public let menuType: ProfileHomeMenuType
    public let title: String
    public let description: String?
    public let actionName: String

    public init(
        section: ProfileHomeSection,
        cellType: ProfileHomeCellType,
        menuType: ProfileHomeMenuType,
        title: String,
        description: String? = nil,
        actionName: String
    ) {
        self.section = section
        self.cellType = cellType
        self.menuType = menuType
        self.title = title
        self.description = description
        self.actionName = actionName
    }
}
