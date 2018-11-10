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
    static func linksWithID(id: Int, request: Request) -> [String:String]? {
        return [
            "href":request.baseURL.appendingPathComponent("builder").appendingPathComponent("\(id)").absoluteString,
            "listings":request.baseURL.appendingPathComponent("builder").appendingPathComponent("\(id)").appendingPathComponent("listings").absoluteString,
            "listingCount":request.baseURL.appendingPathComponent("builder").appendingPathComponent("\(id)").appendingPathComponent("listings").appendingPathComponent("count").absoluteString,
        ]
    }
}


extension DBBuilder {
    func publicBuilder(with request: Request) -> PublicBuilder {
        let b = PublicBuilder(id: id,
                             name: builder,
                             logo: photo.hasPrefix("http") ? photo : nil,
                             paid: paid,
                             adsEnabled: ads_enabled,
                             website: website.hasPrefix("http") ? website : nil,
                             phoneNumber: phone,
                             listingCount: activeListingCount,
                             links: PublicBuilder.linksWithID(id: id!, request: request))
        return b
    }
}

