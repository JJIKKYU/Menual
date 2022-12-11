//
//  WeatherModel.swift
//  Menual
//
//  Created by 정진균 on 2022/05/01.
//

import Foundation
import RealmSwift

// MARK: - Enum
public enum Weather: String, PersistableEnum {
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
        self.uuid = ""
        self.weather = realm.weather
        self.detailText = realm.detailText
    }
}

class WeatherModelRealm: EmbeddedObject {
    // @Persisted(primaryKey: true) var _id: ObjectId
    // @Persisted var uuid: String = ""
    @Persisted var weather: Weather?
    @Persisted var detailText: String = ""
    
    convenience init(weather: Weather?, detailText: String) {
        self.init()
        self.weather = weather
        self.detailText = detailText
    }
    
    convenience init(_ weatherModel: WeatherModel) {
        self.init()
        self.weather = weatherModel.weather
        self.detailText = weatherModel.detailText
    }
}
