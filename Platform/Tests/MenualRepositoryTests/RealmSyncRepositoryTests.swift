//
//  RealmSyncRepositoryTests.swift
//  
//
//  Created by 정진균 on 2023/05/29.
//

import XCTest
import MenualRepository
import MenualEntity

final class RealmSyncRepositoryTests: XCTestCase {
    
    var sut: RealmSyncRepository!

    override func setUpWithError() throws {
        sut = RealmSyncRepository()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testExample() async throws {
        await sut.test()
    }
}
