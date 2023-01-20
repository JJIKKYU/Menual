//
//  PushModel.swift
//  Menual
//
//  Created by 정진균 on 2022/12/17.
//

import Foundation

public struct PushModel: Decodable {
    public let aps: APS
    
    public struct APS: Decodable {
        public let alert: Alert
        
        public struct Alert: Decodable {
            public let title: String
            public let body: String
        }
    }
    
    public  let diaryUUID: String
    
    public  init(decoding userInfo: [AnyHashable : Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
        self = try JSONDecoder().decode(PushModel.self, from: data)
    }
}
