//
//  Subdivision.swift
//  xmlxml
//
//  Created by stephenciauri on 8/10/18.
//

import Foundation
import SWXMLHash

struct BDXSubdivision: Codable {
    let id: String
    let name: String
    let status: Status
    let priceLow: Float?
    let priceHigh: Float?
    let squareFeetLow: Int?
    let squareFeetHigh: Int?
    let email: String?
    let salesOffice: SalesOffice
    let address: BDXAddress?
    let drivingDirections: String?
    let schools: [School]?
    let description: String?
    let amenities: [BDXAmenity]?
    let images: [BDXImage]?
    let plans: [Plan]?
    
    enum Status: String, Codable{
        case active = "Active"
        case grandOpening = "GrandOpening"
        case closeout = "Closeout"
        case comingSoon = "ComingSoon"
    }
}

extension BDXSubdivision {
    init?(withIndexer xml: XMLIndexer) {
        guard
            let idString = xml["SubdivisionNumber"].element?.text,
            let name = xml["SubdivisionName"].element?.text,
            let salesOffice = SalesOffice(withIndexer: xml["SalesOffice"]) else {
                print("Failed to decode listing with id: \(xml["SubdivisionNumber"].element?.text ?? "nil")")
                return nil
        }
        self.id = idString
        self.name = name
        self.salesOffice = salesOffice
        
        if let statusString = xml.element?.attribute(by: "Status")?.text {
            status = Status(rawValue: statusString) ?? .active
        } else {
            status = .active
        }
        
        priceLow = xml.element?.attribute(by: "PriceLow")?.text.toFloat
        priceHigh = xml.element?.attribute(by: "PriceHigh")?.text.toFloat
        squareFeetLow = xml.element?.attribute(by: "SqftLow")?.text.toInt
        squareFeetHigh = xml.element?.attribute(by: "SqftHigh")?.text.toInt
        email = xml["SubLeadsEmail"].element?.text
        address = BDXAddress(withSub: xml["SubAddress"])
        drivingDirections = xml["DrivingDirections"].element?.text
        schools = xml["Schools"].all.compactMap({School(withIndexer: $0)})
        description = xml["SubDescription"].element?.text
        amenities = xml["SubAmenity"].all.compactMap({BDXAmenity(withIndexer: $0)})
        images = xml["SubImage"].all.compactMap({BDXImage(withIndexer: $0)})
        plans = xml["Plan"].all.compactMap({Plan(withIndexer: $0)})
    }
    
    var feedHash: Int {
        return "\(id)\(name)".hashValue
    }
}

extension BDXAddress {
    init?(withSub xml: XMLIndexer) {
        guard let street1 = xml["SubStreet1"].element?.text,
            let city = xml["SubCity"].element?.text,
            let state = xml["SubState"].element?.text,
            let postalCode = xml["SubZIP"].element?.text else {
                return nil
        }
        outOfCommunity = false
        self.street1 = street1
        self.city = city
        self.state = state
        self.postalCode = postalCode
        
        street2 = xml["SubStreet2"].element?.text
        county = xml["SubCounty"].element?.text
        country = xml["SubCountry"].element?.text
        geocode = BDXGeocode(withSub: xml["SubGeocode"])
    }
}

extension BDXGeocode {
    init?(withSub xml: XMLIndexer) {
        guard let lat = xml["SubLatitude"].element?.text.toDouble,
            let long = xml["SubLongitude"].element?.text.toDouble else {
                return nil
        }
        latitude = lat
        longitude = long
    }
}

extension String {
    var toInt: Int? {
        return Int(self)
    }
    
    var toFloat: Float? {
        return Float(self)
    }
    
    var toDouble: Double? {
        return Double(self)
    }
}
