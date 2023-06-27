//
//  AD+Util.swift
//  
//
//  Created by 정진균 on 2023/05/21.
//

import Foundation

public class ADUtil {
    static public var diaryHomeUnitID: String {
        #if DEBUG
        // 디버그모드 이고 디버그 모드를 활성화 했다면, 테스트용 unit ID
        if DebugMode.isAlpha || DebugMode.isDebugMode {
            return "ca-app-pub-3940256099942544/3986624511"
        }
        #else
        if DebugMode.isDebugMode {
            return "ca-app-pub-3940256099942544/3986624511"
        }
        #endif
        return "ca-app-pub-1168603177352985/9261740670"
    }
    
    static public var profileHomeUnitID: String {
        #if DEBUG
        // 디버그모드 이고 디버그 모드를 활성화 했다면, 테스트용 unit ID
        if DebugMode.isAlpha || DebugMode.isDebugMode {
            return "ca-app-pub-3940256099942544/2934735716"
        }
        #else
        if DebugMode.isDebugMode {
            return "ca-app-pub-3940256099942544/2934735716"
        }
        #endif
        return "ca-app-pub-1168603177352985/9525410653"
    }
}
