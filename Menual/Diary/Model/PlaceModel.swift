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

// MARK: - PlaceModel
public struct PlaceModel {
    let uuid: String
    let place: Place?
    let detailText: String
    
    init(uuid: String, place: Place?, detailText: String) {
        self.uuid = uuid
        self.place = place
        self.detailText = detailText
    }
    
    init(_ realm: PlaceModelRealm) {
        self.uuid = realm.uuid
        self.place = realm.place
        self.detailText = realm.detailText
    }
}

class PlaceModelRealm: EmbeddedObject {
    // @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var uuid: String = ""
    @Persisted var place: Place?
    @Persisted var detailText: String = ""
    
    convenience init(uuid: String, place: Place?, detailText: String) {
        self.init()
        self.uuid = uuid
        self.place = place
        self.detailText = detailText
    }
    
    convenience init(_ placeModel: PlaceModel) {
        self.init()
        self.uuid = placeModel.uuid
        self.place = placeModel.place
        self.detailText = placeModel.detailText
    }
}

// MARK: - History PlaceModel
public struct PlaceHistoryModel {
    let uuid: String
    let selectedPlace: Place
    let info: String
    let createdAt: Date
    let isDeleted: Bool
    
    init(uuid: String, selectedPlace: Place, info: String, createdAt: Date, isDeleted: Bool) {
        self.uuid = uuid
        self.selectedPlace = selectedPlace
        self.info = info
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
    
    init(_ model: PlaceHistoryModelRealm) {
        self.uuid = model.uuid
        self.selectedPlace = model.selectedPlace
        self.info = model.info
        self.createdAt = model.createdAt
        self.isDeleted = model.isDeleted
    }
}

class PlaceHistoryModelRealm: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var uuid: String
    @Persisted var selectedPlace: Place
    @Persisted var info: String
    @Persisted var createdAt: Date
    @Persisted var isDeleted: Bool
    
    convenience init(uuid: String, selectedPlace: Place, info: String, createdAt: Date, isDeleted: Bool) {
        self.init()
        self.uuid = uuid
        self.selectedPlace = selectedPlace
        self.info = info
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
    
    convenience init(_ model: PlaceHistoryModel) {
        self.init()
        self.uuid = model.uuid
        self.selectedPlace = model.selectedPlace
        self.info = model.info
        self.createdAt = model.createdAt
        self.isDeleted = model.isDeleted
    }
}
