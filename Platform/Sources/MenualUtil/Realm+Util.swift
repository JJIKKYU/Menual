//
//  Realm+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/12/11.
//

import Foundation
import Realm
import RealmSwift

extension Results {
    public var list: List<Element> {
      reduce(.init()) { list, element in
        list.append(element)
        return list
      }
    }
    
    public func toArray<T>(type: T.Type) -> [T] {
        return compactMap { $0 as? T }
    }
}
