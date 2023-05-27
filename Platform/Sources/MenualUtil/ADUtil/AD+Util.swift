//
//  AD+Util.swift
//  
//
//  Created by 정진균 on 2023/05/21.
//

import Foundation

public class ADUtil {
    static public var diaryHomeUnitID: String {
        if DebugMode.isAlpha || DebugMode.isDebugMode {
            return "ca-app-pub-3940256099942544/3986624511"
        }
            
        return "ca-app-pub-3940256099942544/3986624511"
    }
    
    static public var profileHomeUnitID: String {
        if DebugMode.isAlpha || DebugMode.isDebugMode {
            return "ca-app-pub-3940256099942544/2934735716"
        }
        
        return "ca-app-pub-1168603177352985/9525410653"
    }
}
