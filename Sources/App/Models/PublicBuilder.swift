//
//  PublicBuilder.swift
//  App
//
//  Created by stephenciauri on 8/11/18.
//

import Foundation
import Vapor

struct PublicBuilder: Content {
    let id: Int?
    let name: String
    let logo: String?
    let paid: Bool
    let adsEnabled: Bool
    let website: String?
    let phoneNumber: String?
    
    var listingCount: Int?
    var links: [String:String]?
}

extension PublicBuilder {
    mutating func updateLinks(with request: Request) {
        links = [
            "href":request.baseURL.appendingPathComponent("builder").appendingPathComponent("\(id!)").absoluteString,
            "listings":request.baseURL.appendingPathComponent("builder").appendingPathComponent("\(id!)").appendingPathComponent("listings").absoluteString,
        ]
    }
}


extension DBBuilder {
    var publicBuilder: PublicBuilder {
        return PublicBuilder(id: id, name: builder, logo: photo, paid: paid, adsEnabled: ads_enabled, website: website, phoneNumber: phone, listingCount: nil, links: nil)
    }
}

