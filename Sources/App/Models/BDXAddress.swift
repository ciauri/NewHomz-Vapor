//
//  Address.swift
//  xmlxml
//
//  Created by stephenciauri on 8/11/18.
//

import Foundation

struct BDXAddress: Codable {
    let outOfCommunity: Bool
    let street1: String
    let street2: String?
    let city: String
    let county: String?
    let state: String
    let postalCode: String
    let country: String?
    let geocode: BDXGeocode?
}

struct BDXGeocode: Codable {
    let latitude: Double
    let longitude: Double
}

struct BDXPhone: Codable {
    let areaCode: String
    let prefix: String
    let suffix: String
    let phoneExtension: String?
}
