//
//  Builder.swift
//  xmlxml
//
//  Created by stephenciauri on 8/10/18.
//

import Foundation
import SWXMLHash

struct BDXBuilder: Codable {
    let id: String
    let name: String
    let logoURL: URL?
    let defaultLeadsEmail: String?
    let website: URL?
    let subdivisions: [BDXSubdivision]
    let subsCount: Int?
}


extension BDXBuilder {
    init?(withIndexer xml: XMLIndexer) {
        guard
            let idString = xml["BuilderNumber"].element?.text,
            let name = xml["BrandName"].element?.text else {
                return nil
        }
        self.id = idString
        self.name = name
        logoURL = xml["BrandLogo_Med"].element?.text.toURL
        defaultLeadsEmail = xml["DefaultLeadsEmail"].element?.text
        website = xml["BuilderWebsite"].element?.text.toURL
        subdivisions = xml["Subdivision"].all.compactMap{BDXSubdivision(withIndexer: $0)}
        subsCount = xml["SubsCount"].element?.text.toInt
    }
}

extension BDXBuilder {
    var feedHash: Int {
        return "\(id)\(name)".hashValue
    }
}

extension String {
    var toURL: URL? {
        return URL(string: self)
    }
}
