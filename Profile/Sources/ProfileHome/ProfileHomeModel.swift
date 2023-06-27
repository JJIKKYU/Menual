//
//  ProfileHomeModel.swift
//  Menual
//
//  Created by 정진균 on 2022/06/25.
//

import Foundation

struct ProfileHomeModel {
    let section: ProfileHomeSection
    let type: ProfileHomeCellType
    let title: String
    let description: String?
    let actionName: String
    
    init(section: ProfileHomeSection, type: ProfileHomeCellType, title: String, description: String? = nil, actionName: String) {
        self.section = section
        self.type = type
        self.title = title
        self.description = description
        self.actionName = actionName
    }
}
