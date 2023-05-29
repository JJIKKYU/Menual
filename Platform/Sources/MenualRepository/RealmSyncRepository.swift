//
//  RealmSyncRepository.swift
//  
//
//  Created by 정진균 on 2023/05/28.
//

import Foundation
import RealmSwift
import MenualEntity

public class RealmSyncRepository {
    
    public init () {
        
    }
    
    public func test() async {
        let app = App(id: "menual-hfjcn")
        guard let user = try? await app.login(credentials: Credentials.anonymous) else { return }
        var config = user.flexibleSyncConfiguration()
        
        config.objectTypes = [BackupHistoryModelRealm.self]
        guard let realm = try? await Realm(
            configuration: config,
            downloadBeforeOpen: .always
        ) else { return }
        print("Successfully opened realm: \(realm)")
    }
    
}
