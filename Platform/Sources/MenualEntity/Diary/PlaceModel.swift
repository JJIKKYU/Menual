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
    case place = ""
    case home = "집"
    case school = "학교"
    case company = "회사"
    case travel = "여행"
    
    public func getPlaceText(place: Place) -> String {
        var text = ""
        switch place {
        case .place:
            text = ""
        case .home:
            text = "집"
        case .travel:
            text = "여행"
        case .school:
            text = "학교"
        case .company:
            text = "회사"
        }
        
       return text
    }
    
    public func getVariation() -> [Place] {
        return [.place, .home, .school, .company, .travel]
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
         // place = try container.decode(Place.self, forKey: .place)
        if let placeRawValue = try container.decodeIfPresent(String.self, forKey: .place),
            let place = Place(rawValue: placeRawValue) {
            self.place = place
        } else {
            self.place = nil
        }
        detailText = try container.decode(String.self, forKey: .detailText)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(place?.rawValue ?? "", forKey: .place)
        try container.encode(detailText, forKey: .detailText)
    }
}
