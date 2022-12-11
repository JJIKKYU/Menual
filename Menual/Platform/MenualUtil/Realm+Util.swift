//
//  Realm+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/12/11.
//

import Foundation
import RealmSwift

extension Results {
    func toArray<T>(type: T.Type) -> [T] {
        return compactMap { $0 as? T }
    }
}
