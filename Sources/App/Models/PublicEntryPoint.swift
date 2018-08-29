//
//  PublicEntryPoint.swift
//  App
//
//  Created by stephenciauri on 8/17/18.
//

import Foundation
import Vapor

struct PublicEntryPoint: Content {
    let links: [String:String]
    
    init(req: Request) {
        links = [
            "builders": req.baseURL.appendingPathComponent("builders").absoluteString,
            "builderById": req.baseURL.appendingPathComponent("builder").absoluteString,
            "featuredBuilders": req.baseURL.appendingPathComponent("builders").appendingPathComponent("featured").absoluteString,
            "builderCount": req.baseURL.appendingPathComponent("builders").appendingPathComponent("count").absoluteString,
            "listings": req.baseURL.appendingPathComponent("listings").absoluteString,
            "listingById": req.baseURL.appendingPathComponent("listing").absoluteString,
            "featuredListings": req.baseURL.appendingPathComponent("listings").appendingPathComponent("featured").absoluteString,
            "listingCount": req.baseURL.appendingPathComponent("listings").appendingPathComponent("count").absoluteString,
            "listingsInRegion": req.baseURL.appendingPathComponent("listings").appendingPathComponent("inRegion").absoluteString,
        ]
    }
}
