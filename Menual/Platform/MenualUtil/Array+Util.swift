//
//  Array+Util.swift
//  Menual
//
//  Created by 정진균 on 2022/11/26.
//

import Foundation

extension Array {

    var middle: Element? {
        guard count != 0 else { return nil }

        let middleIndex = (count > 1 ? count - 1 : count) / 2
        return self[middleIndex]
    }

}
