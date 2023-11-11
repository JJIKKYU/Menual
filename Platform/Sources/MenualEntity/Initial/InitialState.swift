//
//  InitialState.swift
//
//
//  Created by 정진균 on 11/11/23.
//

import Foundation

public enum InitialState {
    case idle
    case migration
    case password
    case goHome
}

public enum InitialPasswordState {
    case nonPassword
    case hasPassword
}
