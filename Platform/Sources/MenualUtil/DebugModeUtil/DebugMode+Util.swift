//
//  DebugMode+Util.swift
//  
//
//  Created by 정진균 on 2023/03/01.
//

import Foundation

public class DebugMode {
    static public var isDebugMode: Bool {
        let isDebugMode: Bool = UserDefaults.standard.bool(forKey: "debug")
        return isDebugMode
    }
}
