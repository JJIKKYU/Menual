//
//  Codable+Util.swift
//  
//
//  Created by 정진균 on 2023/02/19.
//

import Foundation

extension Encodable {
    public func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
