//
//  PlaceModel.swift
//  Menual
//
//  Created by 정진균 on 2022/05/01.
//

import Foundation
import RealmSwift

// MARK: - Enum
public enum Place: String, PersistableEnum {
    case home = "홈"
    case school = "스쿨"
    case company = "컴퍼니"
    case car = "카"
    case place = "플레이스"
    
    func getPlaceText(place: Place) -> String {
        var text = ""
        switch place {
        case .place:
            text = "플레이스"
        case .school:
            text = "스쿨"
        case .company:
            text = "컴퍼니"
        case .home:
            text = "홈"
        case .car:
            text = "카"
        }
        
       return text
    }
    
    func getVariation() -> [Place] {
        return [.home, .car, .company, .school, .place]
    }
}

class PlaceModelRealm: EmbeddedObject {
    @Persisted var place: Place?
    @Persisted var detailText: String = ""
    
    convenience init(place: Place?, detailText: String) {
        self.init()
        self.place = place
        self.detailText = detailText
    }
}
