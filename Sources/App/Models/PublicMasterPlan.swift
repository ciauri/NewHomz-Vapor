//
//  PublicMasterPlan.swift
//  App
//
//  Created by stephenciauri on 9/5/18.
//

import Foundation
import Vapor

struct PublicMasterPlan: Content {
    let id: Int?
    let name: String
    let coordinate: Coordinate
    let pinImage: String?
    let builderID: Int?
    var thumbnail: String?
}

extension DBMasterPlan {
    var publicMasterPlan: PublicMasterPlan {
        return PublicMasterPlan(id: id, name: name ?? "", coordinate: Coordinate(latitude: lat ?? 0, longitude: lng ?? 0), pinImage: pinURL, builderID: builderId, thumbnail: nil)
    }
}
