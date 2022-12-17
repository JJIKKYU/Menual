//
//  PushModel.swift
//  Menual
//
//  Created by 정진균 on 2022/12/17.
//

import Foundation

struct PushModel: Decodable {
    let aps: APS
    
    struct APS: Decodable {
        let alert: Alert
        
        struct Alert: Decodable {
            let title: String
            let body: String
        }
    }
    
    let diaryUUID: String
    
    init(decoding userInfo: [AnyHashable : Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        self = try JSONDecoder().decode(PushModel.self, from: data)
    }
}
