//
//  AppUpdateInfoRepositoryTests.swift
//  
//
//  Created by 정진균 on 2023/08/27.
//

import XCTest
import MenualRepository

final class AppUpdateInfoRepositoryTests: XCTestCase {

    private var sut: AppUpdateInfoRepository!

    override func setUpWithError() throws {
        sut = AppUpdateInfoRepositoryImp()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testGetAppVersion() {
        // given
        var appVersion: String?

        // when
        appVersion = sut.getInstalledAppVersion()

        // then
        XCTAssertNotNil(appVersion)
    }

    func testGetLatestVersion() async {
        // given
        var latestsVersion: String?

        // when
        latestsVersion = await sut.getAppStoreVersion()

        // then
        XCTAssertNotNil(latestsVersion)
    }
}
