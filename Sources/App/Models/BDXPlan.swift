//
//  Plan.swift
//  xmlxml
//
//  Created by stephenciauri on 8/11/18.
//

import Foundation
import SWXMLHash


extension BDXSubdivision {
    struct Plan: Codable {
        let id: String
        let name: String
        let type: PlanType
        let bedrooms: Int
        let bathrooms: Int
        let website: String
        
        enum PlanType: String, Codable {
            case singleFamiliy = "SingleFamily"
            case multiFamily = "MultiFamily"
        }
    }
    
    
}

extension BDXSubdivision.Plan {
    init?(withIndexer xml: XMLIndexer) {
        guard let id = xml["PlanNumber"].element?.text,
            let name = xml["PlanName"].element?.text,
            let typeString = xml.element?.attribute(by: "Type")?.text,
            let type = BDXSubdivision.Plan.PlanType(rawValue: typeString),
            let bedrooms = xml["Bedrooms"].element?.text.toInt,
            let bathrooms = xml["Baths"].element?.text.toInt else {
                return nil
        }
        self.id = id
        self.name = name
        self.type = type
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        website = xml["PlanWebsite"].element?.text ?? ""
    }
}
