//
//  Logger.swift
//
//
//  Created by 정진균 on 11/5/23.
//

import Foundation
import os

protocol MenualLoggerProtocol: AnyObject {

}

public class MenualLogger: MenualLoggerProtocol {
    let firebaseLogger: Logger = .init(subsystem: "Log", category: "Firebase")
}
