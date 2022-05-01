//
//  WeatherModel.swift
//  Menual
//
//  Created by 정진균 on 2022/05/01.
//

import Foundation
import RealmSwift

// MARK: - Enum
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

// MARK: - WeatherModel
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

class WeatherModelRealm: EmbeddedObject {
    // @Persisted(primaryKey: true) var _id: ObjectId
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

// MARK: - History WeatherModel
public struct WeatherHistoryModel {
    let uuid: String
    let selectedWeather: Weather
    let info: String
    let createdAt: Date
    let isDeleted: Bool
    
    init(uuid: String, selectedWeather: Weather, info: String, createdAt: Date, isDeleted: Bool) {
        self.uuid = uuid
        self.selectedWeather = selectedWeather
        self.info = info
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
    
    init(_ model: WeatherHistoryModelRealm) {
        self.uuid = model.uuid
        self.selectedWeather = model.selectedWeather
        self.info = model.info
        self.createdAt = model.createdAt
        self.isDeleted = model.isDeleted
    }
}

class WeatherHistoryModelRealm: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var uuid: String
    @Persisted var selectedWeather: Weather
    @Persisted var info: String
    @Persisted var createdAt: Date
    @Persisted var isDeleted: Bool
    
    convenience init(uuid: String, selectedWeather: Weather, info: String, createdAt: Date, isDeleted: Bool) {
        self.init()
        self.uuid = uuid
        self.selectedWeather = selectedWeather
        self.info = info
        self.createdAt = createdAt
        self.isDeleted = isDeleted
    }
    
    convenience init(_ model: WeatherHistoryModel) {
        self.init()
        self.uuid = model.uuid
        self.selectedWeather = model.selectedWeather
        self.info = model.info
        self.createdAt = model.createdAt
        self.isDeleted = model.isDeleted
    }
}
