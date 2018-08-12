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
    
    func index(_ req: Request) throws -> Future<[PublicListing]> {
        return DBListing.query(on: req)
            .join(\DBBuilder.id, to: \DBListing.builderID)
            .filter(\.active > 0)
            .alsoDecode(DBBuilder.self)
            .all()
            .then({ (resultArray) -> EventLoopFuture<[PublicListing]> in
                return req.future(ListingController.publicListings(from: resultArray, request: req))
            })
    }
    
    func featured(_ req: Request) throws -> Future<[PublicListing]> {
        return DBListing.query(on: req)
            .join(\DBBuilder.id, to: \DBListing.builderID)
            .filter(\.active > 1)
            .alsoDecode(DBBuilder.self)
            .all()
            .then({ (resultArray) -> EventLoopFuture<[PublicListing]> in
                return req.future(ListingController.publicListings(from: resultArray, request: req))
            })
    }
    
    
    func map(_ req: Request) throws -> Future<[PublicListing]> {
        guard let latStart = try? req.query.get(Double.self, at: "latStart"),
            let latStop = try? req.query.get(Double.self, at: "latStop"),
            let lonStart = try? req.query.get(Double.self, at: "lonStart"),
            let lonStop = try? req.query.get(Double.self, at: "lonStop") else {
                return req.future([])
        }
        return DBListing.query(on: req)
            .join(\DBBuilder.id, to: \DBListing.builderID)
            .filter(\.active > 0)
            .filter(\.lat >= latStart)
            .filter(\.lat <= latStop)
            .filter(\.lng >= lonStart)
            .filter(\.lng <= lonStop)
            .alsoDecode(DBBuilder.self)
            .all()
            .then({ (resultArray) -> EventLoopFuture<[PublicListing]> in
                return req.future(ListingController.publicListings(from: resultArray, request: req))
            })
    }
    
    func withId(_ req: Request) throws -> Future<PublicListing> {
        guard let id = try? req.parameters.next(Int.self) else {
            return req.future(error: NotFound())
        }
        return DBListing.query(on: req)
            .join(\DBBuilder.id, to: \DBListing.builderID)
            .filter(\DBListing.id == id)
            .alsoDecode(DBBuilder.self)
            .all()
            .then({ (resultArray) -> EventLoopFuture<PublicListing?> in
                return req.future(ListingController.publicListings(from: resultArray, request: req).first)
            }).unwrap(or: NotFound())
    }
    
    func gallery(_ req: Request) throws -> Future<[DBGalleryImage]> {
        guard let id = try? req.parameters.next(Int.self) else {
            return req.future(error: NotFound())
        }
        return DBGalleryImage.query(on: req)
            .filter(\.cID == id)
            .all()
    }
    
    func floorplans(_ req: Request) throws -> Future<[DBFloorplanImage]> {
        guard let id = try? req.parameters.next(Int.self) else {
            return req.future(error: NotFound())
        }
        return DBFloorplanImage.query(on: req)
            .filter(\.cID == id)
            .all()
    }

    
    static func publicListings(from results: [(DBListing, DBBuilder)], request: Request) -> [PublicListing] {
        return results.map({ (result) -> PublicListing in
            var listing = result.0.publicListing
            listing.builder = result.1.publicBuilder
            listing.updateLinks(with: request)
            return listing
        })
    }
}