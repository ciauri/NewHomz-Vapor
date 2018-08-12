//
//  EntryPointController.swift
//  App
//
//  Created by stephenciauri on 8/12/18.
//

import Foundation
import Vapor

final class EntryPointController {
    // MARK: - Handlers
    
    func index(_ req: Request) throws -> Future<[String:String]> {
        return req.future([
            "builders": req.baseURL.appendingPathComponent("builders").absoluteString,
            "featuredBuilders": req.baseURL.appendingPathComponent("builders").appendingPathComponent("featured").absoluteString,
            "listings": req.baseURL.appendingPathComponent("listings").absoluteString,
            "featuredListings": req.baseURL.appendingPathComponent("listings").appendingPathComponent("featured").absoluteString,
            "listingsInRegion": req.baseURL.appendingPathComponent("listings").appendingPathComponent("inRegion").absoluteString,
        ])
    }
}
