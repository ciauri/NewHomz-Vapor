//
//  School.swift
//  xmlxml
//
//  Created by stephenciauri on 8/11/18.
//

import Foundation
import SWXMLHash

extension BDXSubdivision {
    struct School: Codable {
        enum Level: String, Codable {
            case elementary
            case middle
            case high
        }
        let name: String
        let districtName: String
        let level: Level
    }
}

extension BDXSubdivision.School {
    init?(withIndexer xml: XMLIndexer) {
        guard let districtName = xml["DistrictName"].element?.text else {
            return nil
        }
        self.districtName = districtName
        if let name = xml["Elementary"].element?.text {
            self.name = name
            level = .elementary
        } else if let name = xml["Middle"].element?.text {
            self.name = name
            level = .middle
        } else if let name = xml["High"].element?.text {
            self.name = name
            level = .high
        } else {
            return nil
        }
    }
}
