//
//  Swift+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/04/16.
//

import Foundation
import RealmSwift
import Realm

// safe array index 탐색
public extension Array {
    public subscript (safe index: Int) -> Element? {
        return self.indices ~= index ? self[index] : nil
    }
}

extension Realm {
    static func safeInit() -> Realm? {
        do {
            let realm = try Realm()
            return realm
        }
        catch {
            // LOG ERROR
        }
        return nil
    }

    func safeWrite(_ block: () -> ()) {
        do {
            // Async safety, to prevent "Realm already in a write transaction" Exceptions
            if !isInWriteTransaction {
                try write(block)
            }
        } catch {
            // LOG ERROR
        }
    }
}
