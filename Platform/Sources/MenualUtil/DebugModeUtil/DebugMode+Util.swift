//
//  DebugMode+Util.swift
//  
//
//  Created by 정진균 on 2023/03/01.
//

import Foundation

public class DebugMode {
    static public var isDebugMode: Bool {
        #if DEBUG
            return true
        #else
            let isDebugMode: Bool = UserDefaults.standard.bool(forKey: "debug")
            return isDebugMode
        #endif
    }
    
    static public var isAlpha: Bool {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            if bundleIdentifier == "com.jjikkyu.menualAlpha" {
                return true
            }
        }
        
        return false
    }
}
