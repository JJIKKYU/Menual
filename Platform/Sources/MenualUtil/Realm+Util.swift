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

extension Object {
    public func toDictionary() -> [String: Any] {
        let properties = self.objectSchema.properties.map { $0.name }
        var mutabledic = self.dictionaryWithValues(forKeys: properties)
        for prop in self.objectSchema.properties as [Property] {
            // find lists
            if let nestedObject = self[prop.name] as? Object {
                mutabledic[prop.name] = nestedObject.toDictionary()
            } else if let nestedListObject = self[prop.name] as? RLMSwiftCollectionBase {
                var objects = [[String: Any]]()
                for index in 0..<nestedListObject._rlmCollection.count  {
                    let object = nestedListObject._rlmCollection[index] as! Object
                    objects.append(object.toDictionary())
                }
                mutabledic[prop.name] = objects
            }
        }
        return mutabledic
    }
}
