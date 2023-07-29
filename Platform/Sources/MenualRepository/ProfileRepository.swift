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
                title: "개발자 도구",
                actionName: "devTools"
            ),
            .init(
                section: .devMode,
                cellType: .arrow,
                menuType: .devMode(.designSystem),
                title: "디자인 시스템",
                actionName: "designSystem"
            ),
            .init(
                section: .devMode,
                cellType: .toggleWithDescription,
                menuType: .devMode(.alarm),
                title: "일기 작성 알림 설정하기",
                description: "일기를 꾸준히 쓸 수 있도록 알림을 보내드릴게요",
                actionName: "review"
            ),
        ]
    }
}
