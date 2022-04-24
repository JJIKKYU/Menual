//
//  DiarySubDataModel.swift
//  Menual
//
//  Created by 정진균 on 2022/04/17.
//

import Foundation
import RealmSwift

// MARK: - Weather

enum Weather: String, PersistableEnum {
    case sun = "썬"
    case rain = "레인"
    case cloud = "클라우드"
    case thunder = "썬더"
    case snow = "스노우"
    
    func getWeatherText(weather: Weather) -> String {
        var text = ""
        switch weather {
        case .sun:
            text = "썬"
        case .thunder:
            text = "썬더"
        case .cloud:
            text = "클라우드"
        case .rain:
            text = "레인"
        case .snow:
            text = "스노우"
        }
        
       return text
    }
    
    func getVariation() -> [Weather] {
        return [.sun, .rain, .cloud, .thunder, .snow]
    }
}

public struct WeatherModel {
    let uuid: String
    let weather: Weather?
    let detailText: String
    
    init(uuid: String, weather: Weather?, detailText: String) {
        self.uuid = uuid
        self.weather = weather
        self.detailText = detailText
    }
    
    init(_ realm: WeatherModelRealm) {
        self.uuid = realm.uuid
        self.weather = realm.weather
        self.detailText = realm.detailText
    }
}

class WeatherModelRealm: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var uuid: String = ""
    @Persisted var weather: Weather?
    @Persisted var detailText: String = ""
    
    convenience init(uuid: String, weather: Weather?, detailText: String) {
        self.init()
        self.uuid = uuid
        self.weather = weather
        self.detailText = detailText
    }
    
    convenience init(_ weatherModel: WeatherModel) {
        self.init()
        self.uuid = weatherModel.uuid
        self.weather = weatherModel.weather
        self.detailText = weatherModel.detailText
    }
}

// MARK: - Place

enum Place: String, PersistableEnum {
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

class PlaceModelRealm: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
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
