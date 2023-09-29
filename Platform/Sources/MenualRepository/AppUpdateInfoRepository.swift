//
//  AppUpdateInfoRepository.swift
//
//
//  Created by 정진균 on 2023/08/27.
//

import Foundation
import MenualEntity
import MenualUtil
import RxRelay
import RxSwift

// MARK: - AppUpdateInfoRepository

public protocol AppUpdateInfoRepository: AnyObject {
    func saveAppVersion()
    func getInstalledAppVersion() -> String
    func getSavedAppVersion() -> String
    func getAppStoreVersion() async -> String?
    func compareVersions(_ version1: String, _ version2: String) -> ComparisonResult
    func checkNeedUpdateLog()

    var shouldShowUpdateObservable: Observable<Bool> { get }
}

// MARK: - AppUpdateInfoRepositoryImp

public class AppUpdateInfoRepositoryImp: AppUpdateInfoRepository {
    public var shouldShowUpdateObservable: Observable<Bool> {
        shouldShowUpdateRelay.asObservable()
    }
    private let shouldShowUpdateRelay: BehaviorRelay<Bool> = .init(value: false)

    public init() {
        // let result = compareVersions(getInstalledAppVersion(), getSavedAppVersion())
        // print("AppUpdateInfoRepository :: compareResult = \(result)")

        checkNeedUpdateLog()
        // saveAppVersion()
    }

    // 업데이트 내역을 표시할 필요가 있는지 체크하는 함수
    public func checkNeedUpdateLog() {
        // DebugMode일 경우 나타나는 것 강제 세팅
        /*
        if DebugMode.isDebugMode || DebugMode.isAlpha {
            UserDefaults().setValue("2.2.1", forKey: UserDefaultsModel.appVersion.rawValue)
        }
        */

        // 설치된 버전이 저장된 버전보다 클 경우에 표시해야 함
        let result: ComparisonResult = compareVersions(getInstalledAppVersion(), getSavedAppVersion())

        switch result {
        // 설치된 버전이 저장된 버전보다 클 경우 (내역 표시해야 함)
        case .orderedDescending:
            print("AppUpdateInfoRepository :: 설치된 버전이 저장된 버전보다 크므로 내역을 표시합니다.")
            shouldShowUpdateRelay.accept(true)

        // 설치된 버전이 저장된 버전보다 작을 경우 (내역 표시 X)
        case .orderedAscending:
            print("AppUpdateInfoRepository :: 설치된 버전이 저장된 버전보다 작으므로 표시할 필요가 없습니다.")

        // 설치된 버전과 저장된 버전이 같을 경우 (내역 표시 X)
        case .orderedSame:
            print("AppUpdateInfoRepository :: 두 버전이 같아 내역 표시가 필요 없습니다.")
        }
    }

    // 앱 실행마다 현재 앱 버전을 UserDefaults에 저장하는 로직
    public func saveAppVersion() {
        print("AppUpdateInfoRepository :: getAppVersion = \(UserDefaults().value(forKey: UserDefaultsModel.appVersion.rawValue))")
        let currentVersion: String = getInstalledAppVersion()
        print("AppUpdateInfoRepository :: SetAppVersion = \(currentVersion)")
        UserDefaults().setValue(currentVersion, forKey: UserDefaultsModel.appVersion.rawValue)
    }

    // 두 버전을 비교하는 함수
    // orderedAscending = 첫 번째 버전이 두 번째 버전보다 작음
    // orderedDescending = 첫 번째 버전이 두 번쨰 버전보다 큼
    // orderedSame = 첫 번째 두 번째 버전이 같음
    public func compareVersions(_ version1: String, _ version2: String) -> ComparisonResult {
        let components1: [Int] = version1.split(separator: ".").compactMap { Int($0) }
        let components2: [Int] = version2.split(separator: ".").compactMap { Int($0) }

        for (comp1, comp2) in zip(components1, components2) {
            if comp1 < comp2 {
                return .orderedAscending
            } else if comp1 > comp2 {
                return .orderedDescending
            }
        }

        if components1.count < components2.count {
            return .orderedAscending
        } else if components1.count > components2.count {
            return .orderedDescending
        }

        return .orderedSame
    }

    // 현재 설치된 앱의 버전을 얻는 함수
    public func getInstalledAppVersion() -> String {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String,
              let build = dictionary["CFBundleVersion"] as? String else { return "" }

        let versionAndBuild: String = "vserion: \(version), build: \(build)"
        print("AppUpdateInfoRepository :: versionAndBuild = \(versionAndBuild)")
        return version
    }

    // UserDefaults에 저장된 앱의 버전을 얻는 함수
    public func getSavedAppVersion() -> String {
        guard let appVersion: String = UserDefaults().value(forKey: UserDefaultsModel.appVersion.rawValue) as? String else { return "" }
        print("AppUpdateInfoRepository :: getSavedAppVersion -> \(appVersion)")
        return appVersion
    }

    // 현재 앱스토어에 업데이트 되어 있는 최신 버전
    public func getAppStoreVersion() async -> String? {
        var bundleIdentifier: String = ""
        if DebugMode.isAlpha {
            bundleIdentifier = "com.jjikkyu.menualAlpha"
        } else {
            bundleIdentifier = "com.jjikkyu.menual"
        }

        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleIdentifier)"),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let results = json["results"] as? [[String: Any]],
              let appStoreVersion = results.first?["version"] as? String
        else {
            return nil
        }

        print("AppUpdateInfoRepository :: AppStoreVersion = \(appStoreVersion)")

        return appStoreVersion
    }
}
