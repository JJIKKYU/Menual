//
//  WeatherModel.swift
//  Menual
//
//  Created by 정진균 on 2022/05/01.
//

import Foundation
import RealmSwift

// MARK: - Enum
public enum Weather: String, PersistableEnum, Codable {
    case sun = "맑음"
    case rain = "비"
    case cloud = "흐림"
    case thunder = "천둥번개"
    case snow = "눈"
    case wind = "바람"
    
    public func getWeatherText(weather: Weather) -> String {
        var text = ""
        switch weather {
        case .sun:
            text = "맑음"
        case .thunder:
            text = "천둥번개"
        case .cloud:
            text = "흐림"
        case .rain:
            text = "비"
        case .snow:
            text = "눈"
        case .wind:
            text = "바람"
        }
        
       return text
    }
    
    public func getVariation() -> [Weather] {
        return [.sun, .cloud, .rain, .snow, .wind, .thunder]
    }
}

public class WeatherModelRealm: EmbeddedObject, Codable {
    @Persisted public var weather: Weather?
    @Persisted public var detailText: String = ""
    
    public convenience init(weather: Weather?, detailText: String) {
        self.init()
        self.weather = weather
        self.detailText = detailText
    }
    
    enum CodingKeys: String,CodingKey {
        case weather
        case detailText
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        weather = try container.decode(Weather.self, forKey: .weather)
        detailText = try container.decode(String.self, forKey: .detailText)
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
