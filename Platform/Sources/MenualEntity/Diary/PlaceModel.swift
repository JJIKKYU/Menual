//
//  PlaceModel.swift
//  Menual
//
//  Created by 정진균 on 2022/05/01.
//

import Foundation
import RealmSwift

// MARK: - Enum
public enum Place: String, PersistableEnum, Codable {
    case place = ""
    case home = "집"
    case bus = "버스"
    case subway = "지하철"
    case store = "가게"
    case travel = "여행"
    case school = "학교"
    case company = "회사"
    case car = "차 안"
    
    public func getPlaceText(place: Place) -> String {
        var text = ""
        switch place {
        case .place:
            text = ""
        case .home:
            text = "집"
        case .bus:
            text = "버스"
        case .subway:
            text = "지하철"
        case .store:
            text = "가게"
        case .travel:
            text = "여행"
        case .school:
            text = "학교"
        case .company:
            text = "회사"
        case .car:
            text = "차 안"
        }
        
       return text
    }
    
    public func getVariation() -> [Place] {
        return [.place, .home, .company, .school, .bus, .subway, .store, .travel, .car]
    }
}

public class PlaceModelRealm: EmbeddedObject, Codable {
    @Persisted public var place: Place?
    @Persisted public var detailText: String = ""
    
    public convenience init(place: Place?, detailText: String) {
        self.init()
        self.place = place
        self.detailText = detailText
    }
    
    enum CodingKeys: String,CodingKey {
        case place
        case detailText
    }
    
    public override init() {
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        place = try container.decode(Place.self, forKey: .place)
        detailText = try container.decode(String.self, forKey: .detailText)
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
