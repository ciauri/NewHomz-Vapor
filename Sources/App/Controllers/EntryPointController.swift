//
//  EntryPointController.swift
//  App
//
//  Created by stephenciauri on 8/12/18.
//

import Foundation
import Vapor

final class EntryPointController: RouteCollection {
    func boot(router: Router) throws {
        router.grouped(CacheMiddleware(duration: 86400)).get("/", use: index)
    }

    // MARK: - Handlers
    
    func index(_ req: Request) throws -> Future<PublicEntryPoint> {
        return req.future(PublicEntryPoint(req: req))
    }
}
