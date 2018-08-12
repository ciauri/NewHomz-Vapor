//
//  PublicListing.swift
//  App
//
//  Created by stephenciauri on 8/12/18.
//

import Foundation
import Vapor

struct PublicListing: Content {
    let id: Int?
    let name: String
    let priceRange: IntRange
    let squareFeetRange: IntRange
    let bedRange: IntRange
    let bathRange: FloatRange
    let location: Location
    let website: String?
    let phoneNumber: String?
    let propertyType: String
    let lotSize: Int
    let youtubeID: String
    
    var builder: PublicBuilder?
    var links: [String:String]?
}

struct Location: Content {
    let coordinate: Coordinate
    let city: String
    let state: String
    let county: String
    let schoolDistrict: String?
    let postalCode: String?
}

struct Coordinate: Content {
    let latitude: Double
    let longitude: Double
}

struct IntRange: Content {
    let min: Int
    let max: Int
}

struct FloatRange: Content {
    let min: Float
    let max: Float
}

extension PublicListing {
    mutating func updateLinks(with request: Request) {
        builder?.updateLinks(with: request)
        links = [
            "href":request.baseURL.appendingPathComponent("listing").appendingPathComponent("\(id!)").absoluteString,
            "gallery":request.baseURL.appendingPathComponent("listing").appendingPathComponent("\(id!)").appendingPathComponent("gallery").absoluteString,
            "floorplans":request.baseURL.appendingPathComponent("listing").appendingPathComponent("\(id!)").appendingPathComponent("floorplans").absoluteString,
        ]
    }
}

extension DBListing {
    var publicListing: PublicListing {
        return PublicListing(id: id,
                             name: listing,
                             priceRange: IntRange(min: priceLow, max: priceHigh),
                             squareFeetRange: IntRange(min: sqftLow, max: sqftHigh),
                             bedRange: IntRange(min: bedLow, max: bedHigh),
                             bathRange: FloatRange(min: bathLow, max: bathHigh),
                             location: Location(coordinate: Coordinate(latitude: lat, longitude: lng),
                                                city: city,
                                                state: state,
                                                county: county,
                                                schoolDistrict: schoolDistrictName,
                                                postalCode: String(zip)),
                             website: website,
                             phoneNumber: phone,
                             propertyType: propType,
                             lotSize: lot,
                             youtubeID: vid,
                             builder: nil, links: nil)
    }
}


