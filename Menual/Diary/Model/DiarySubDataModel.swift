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
    case sun = "sun"
    case rain = "rain"
    case cloud = "cloud"
    case thunder = "thunder"
    case snow = "snow"
    
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
    case home = "home"
    case school = "school"
    case company = "company"
    case car = "car"
    case place = "place"
}
