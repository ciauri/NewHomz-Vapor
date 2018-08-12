//
//  ListingController.swift
//  App
//
//  Created by stephenciauri on 8/11/18.
//

import Foundation
import Vapor
import FluentMySQL


final class ListingController {
    // MARK: - Handlers
    
    func index(_ req: Request) throws -> Future<[DBListing]> {
        return DBListing.query(on: req)
            .filter(\.active > 0)
            .all()
    }
    
    func featured(_ req: Request) throws -> Future<[DBListing]> {
        return DBListing.query(on: req)
            .filter(\.active > 1)
            .all()
    }
    
    func withId(_ req: Request) throws -> Future<DBListing> {
        guard let id = try? req.parameters.next(Int.self) else {
            return req.future(error: NotFound())
        }
        return DBListing.query(on: req)
            .filter(\.id == id)
            .first()
            .unwrap(or: NotFound())
    }

    func map(_ req: Request) throws -> Future<[DBListing]> {
        guard let latStart = try? req.query.get(Double.self, at: "latStart"),
        let latStop = try? req.query.get(Double.self, at: "latStop"),
        let lonStart = try? req.query.get(Double.self, at: "lonStart"),
        let lonStop = try? req.query.get(Double.self, at: "lonStop") else {
            return req.future([])
        }
        return DBListing.query(on: req)
            .filter(\.active > 0)
            .filter(\.lat >= latStart)
            .filter(\.lat <= latStop)
            .filter(\.lng >= lonStart)
            .filter(\.lng <= lonStop)
            .all()
    }
}
