//
//  ProfileRepository.swift
//  Menual
//
//  Created by 정진균 on 2023/07/29.
//

import DesignSystem
import Foundation
import MenualEntity

public protocol ProfileRepository {
    func fetchSetting1ProfileMenu() -> [ProfileHomeMenuModel]
    func fetchSetting2ProfileMenu() -> [ProfileHomeMenuModel]
    func fetchSettingDevModeMenu() -> [ProfileHomeMenuModel]
}

public final class ProfileRepositoryImp: ProfileRepository {
    public init() {}

    public func fetchSetting1ProfileMenu() -> [ProfileHomeMenuModel] {
        return [
            .init(
                section: .setting1,
                cellType: .arrow,
                menuType: .setting1(.guide),
                title: MenualString.profile_button_guide,
                actionName: "showGuide"
            ),
            .init(
                section: .setting1,
                cellType: .toggle,
                menuType: .setting1(.password),
                title: MenualString.profile_button_set_password,
                actionName: "setPassword"
            ),
            .init(
                section: .setting1,
                cellType: .arrow,
                menuType: .setting1(.passwordChange),
                title: MenualString.profile_button_change_password,
                actionName: "changePassword"
            ),
        ]
    }

    public func fetchSetting2ProfileMenu() -> [ProfileHomeMenuModel] {
        return [
            .init(
                section: .setting2,
                cellType: .arrow,
                menuType: .setting2(.backup),
                title: MenualString.profile_button_backup,
                actionName: "backup"
            ),
            .init(
                section: .setting2,
                cellType: .arrow,
                menuType: .setting2(.restore),
                title: MenualString.profile_button_restore,
                actionName: "load"
            ),
            .init(
                section: .setting2,
                cellType: .arrow,
                menuType: .setting2(.mail),
                title: MenualString.profile_button_mail,
                actionName: "mail"
            ),
            .init(
                section: .setting2,
                cellType: .arrow,
                menuType: .setting2(.openSource),
                title: MenualString.profile_button_openSource,
                actionName: "openSource"
            ),
        ]
    }
    
    public func fetchSettingDevModeMenu() -> [ProfileHomeMenuModel] {
        return [
            .init(
                section: .devMode,
                cellType: .arrow,
                menuType: .devMode(.tools),
                title: MenualString.profile_button_dev,
                actionName: "devTools"
            ),
            .init(
                section: .devMode,
                cellType: .arrow,
                menuType: .devMode(.designSystem),
                title: MenualString.profile_button_designsystem,
                actionName: "designSystem"
            ),
            .init(
                section: .devMode,
                cellType: .toggleWithDescription,
                menuType: .devMode(.alarm),
                title: MenualString.profile_button_alarm,
                description: MenualString.profile_button_alarm_subtitle,
                actionName: "alarm"
            ),
        ]
    }
}
