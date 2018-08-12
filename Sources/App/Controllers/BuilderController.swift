//
//  BuilderController.swift
//  App
//
//  Created by stephenciauri on 8/11/18.
//

import Foundation
import Vapor
import FluentMySQL


final class BuilderController {
    // MARK: - Handlers
    
    func index(_ req: Request) throws -> Future<[PublicBuilder]> {
        return DBBuilder.query(on: req)
            .join(\DBListing.builderID, to: \DBBuilder.id)
            .filter(\DBListing.active > 0)
            .alsoDecode(DBListing.self)
            .all()
            .then({ (resultArray) -> EventLoopFuture<[PublicBuilder]> in
                return req.future(BuilderController.publicBuilders(for: resultArray, request: req))
            })
    }
    
    func featured(_ req: Request) throws -> Future<[PublicBuilder]> {
        return DBBuilder.query(on: req)
            .join(\DBListing.builderID, to: \DBBuilder.id)
            .filter(\DBBuilder.paid == true)
            .filter(\DBListing.active > 0)
            .alsoDecode(DBListing.self)
            .all()
            .then({ (resultArray) -> EventLoopFuture<[PublicBuilder]> in
                return req.future(BuilderController.publicBuilders(for: resultArray, request: req))
        })
    }
    
    func withId(_ req: Request) throws -> Future<PublicBuilder> {
        guard let id = try? req.parameters.next(Int.self) else {
            return req.future(error: NotFound())
        }
        return DBBuilder.query(on: req)
            .join(\DBListing.builderID, to: \DBBuilder.id)
            .filter(\DBBuilder.id == id)
            .filter(\DBListing.active > 0)
            .alsoDecode(DBListing.self)
            .all()
            .then({ (resultArray) -> EventLoopFuture<PublicBuilder?> in
                return req.future(BuilderController.publicBuilders(for: resultArray, request: req).first)
            }).unwrap(or: NotFound())
    }
    
    func listings(_ req: Request) throws -> Future<[PublicListing]> {
        guard let id = try? req.parameters.next(Int.self) else {
            return req.future(error: NotFound())
        }
        return DBListing.query(on: req)
            .join(\DBBuilder.id, to: \DBListing.builderID)
            .filter(\.active > 0)
            .filter(\.builderID == id)
            .alsoDecode(DBBuilder.self)
            .all()
            .then({ (resultArray) -> EventLoopFuture<[PublicListing]> in
                return req.future(ListingController.publicListings(from: resultArray, request: req))
            })
    }
    

    
    
    // MARK: - Transformation
    static func publicBuilders(for result: [(DBBuilder, DBListing)], request: Request) -> [PublicBuilder] {
        let builders: Set<DBBuilder> = Set(result.map({$0.0}))
        var listings: [DBListing] = result.map({$0.1})
        var publicBuilders: [PublicBuilder] = []
        for builder in builders {
            let initialCount = listings.count
            listings = listings.filter({$0.builderID != builder.id!})
            let finalCount = listings.count
            let listingCount = initialCount - finalCount
            var publicBuilder = builder.publicBuilder
            publicBuilder.listingCount = listingCount
            publicBuilder.updateLinks(with: request)
            publicBuilders.append(publicBuilder)
        }
        return publicBuilders
    }
}

extension Request {
    var baseURL: URL {
        return URL(string: "https://\(http.headers.firstValue(name: .host)!)")!
    }
}
