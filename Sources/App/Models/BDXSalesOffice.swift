//
//  SalesOffice.swift
//  xmlxml
//
//  Created by stephenciauri on 8/11/18.
//

import Foundation
import SWXMLHash

extension BDXSubdivision {
    struct SalesOffice: Codable {
        let agent: String?
        let address: BDXAddress
        let phone: BDXPhone?
        let hours: String?
    }
}

extension BDXSubdivision.SalesOffice {
    init?(withIndexer xml: XMLIndexer) {
        guard let address = BDXAddress(withSalesOffice: xml["Address"]) else {
            return nil
        }
        agent = xml["Agent"].element?.text
        self.address = address
        self.phone = BDXPhone(withSalesOffice: xml["Phone"])
        hours = xml["Hours"].element?.text
    }
}

// MARK: - SalesOffice Serialization


extension BDXAddress {
    init?(withSalesOffice xml: XMLIndexer) {
        guard let street1 = xml["Street1"].element?.text,
            let city = xml["City"].element?.text,
            let state = xml["State"].element?.text,
            let postalCode = xml["ZIP"].element?.text else {
                return nil
        }
        outOfCommunity = xml.element?.attribute(by: "OutOfCommunity")?.text.toInt ?? 0 > 0
        self.street1 = street1
        self.city = city
        self.state = state
        self.postalCode = postalCode
        
        street2 = xml["Street2"].element?.text
        county = xml["County"].element?.text
        country = xml["Country"].element?.text
        geocode = BDXGeocode(withSalesOffice: xml["Geocode"])
    }
}

extension BDXGeocode {
    init?(withSalesOffice xml: XMLIndexer) {
        guard let lat = xml["Latitude"].element?.text.toDouble,
            let long = xml["Longitude"].element?.text.toDouble else {
                return nil
        }
        latitude = lat
        longitude = long
    }
}

extension BDXPhone {
    init?(withSalesOffice xml: XMLIndexer) {
        guard let areaCode = xml["AreaCode"].element?.text,
            let prefix = xml["Prefix"].element?.text,
            let suffix = xml["Suffix"].element?.text else {
                return nil
        }
        self.areaCode = areaCode
        self.prefix = prefix
        self.suffix = suffix
        phoneExtension = xml["Extension"].element?.text
    }
    
    var phoneString: String {
        return prefix+areaCode+suffix+"\(phoneExtension != nil ? "ext "+phoneExtension! : "")"
    }
}
