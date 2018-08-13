//
//  Amenity.swift
//  xmlxml
//
//  Created by stephenciauri on 8/11/18.
//

import Foundation
import SWXMLHash

extension BDXSubdivision {
    struct BDXAmenity: Codable {
        let type: AmenityType
        let available: Bool
        enum AmenityType: String, Codable {
            case pool = "Pool"
            case playground = "Playground"
            case GolfCourse = "GolfCourse"
            case tennis = "Tennis"
            case soccer = "Soccer"
            case volleyball = "Volleyball"
            case basketball = "Basketball"
            case baseball = "Baseball"
            case views = "Views"
            case lake = "Lake"
            case pond = "Pond"
            case marina = "Marina"
            case beach = "Beach"
            case waterfront = "Waterfront"
            case park = "Park"
            case trails = "Trails"
            case greenbelt = "Greenbelt"
            case clubhouse = "Clubhouse"
            case communityCenter = "CommunityCenter"
        }
    }
}

extension BDXSubdivision.BDXAmenity {
    init?(withIndexer xml: XMLIndexer) {
        guard let typeString = xml.element?.attribute(by: "Type")?.text,
            let type = AmenityType(rawValue: typeString) else {
                return nil
        }
        available = xml.element?.text.toInt ?? 0 > 0
        self.type = type
    }
}
