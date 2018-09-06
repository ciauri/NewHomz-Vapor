//
//  BuilderController.swift
//  App
//
//  Created by stephenciauri on 8/11/18.
//

import Foundation
import Vapor
import FluentMySQL


final class BuilderController: RouteCollection {
    
    // Register Controller
    func boot(router: Router) throws {
        router.grouped(CacheMiddleware(duration: 86400)).get("builders", use: index)
        router.get("builders", "featured", use: featured)
        router.get("builders", "count", use: count)
        router.get("builder", use: withId)
        router.get("builder", Int.parameter, use: withId)
        router.get("builder", Int.parameter, "listings", use: listings)
        router.get("builder", Int.parameter, "listings", "count", use: listingCount)
    }
    
    // MARK: - Handlers
    
    func index(_ req: Request) throws -> Future<[PublicBuilder]> {
        if let offset = try? req.query.get(Int.self, at: "offset") {
            return try indexWithOffset(req, offset: offset)
        } else {
            return DBBuilder.query(on: req)
                .filter(\DBBuilder.activeListingCount > 0)
                .all()
                .then({ (builders) -> EventLoopFuture<[PublicBuilder]> in
                    let publicBuilders = builders.map({$0.publicBuilder(with: req)})
                    return req.future(publicBuilders)
                })
        }
    }
    
    func indexWithOffset(_ req: Request, offset: Int) throws -> Future<[PublicBuilder]> {
        guard offset > 0 else {
            return req.future([])
        }
        return DBBuilder.query(on: req)
            .filter(\DBBuilder.activeListingCount > 0)
            .range(lower: offset, upper: offset + 100)
            .all()
            .then({ (builders) -> EventLoopFuture<[PublicBuilder]> in
                return req.future(builders.map({$0.publicBuilder(with: req)}))
            })
    }
    
    func featured(_ req: Request) throws -> Future<[PublicBuilder]> {
        return DBBuilder.query(on: req)
            .filter(\DBBuilder.paid == true)
            .filter(\DBBuilder.activeListingCount > 0)
            .all()
            .then({ (builders) -> EventLoopFuture<[PublicBuilder]> in
                return req.future(builders.map({$0.publicBuilder(with: req)}))
        })
    }
    
    func withId(_ req: Request) throws -> Future<PublicBuilder> {
        guard let id = (try? req.parameters.next(Int.self)) ?? (try? req.query.get(Int.self, at: "id")) else {
            return req.future(error: NotFound())
        }
        return DBBuilder.find(id, on: req)
            .unwrap(or: NotFound())
            .then({ (builder) -> EventLoopFuture<PublicBuilder> in
                return req.future(builder.publicBuilder(with: req))
            })
    }
    
    func count(_ req: Request) throws -> Future<Int> {
        return DBBuilder.query(on: req)
            .filter(\.activeListingCount > 0)
            .count()
    }
    
    func listingCount(_ req: Request) throws -> Future<Int> {
        guard let id = try? req.parameters.next(Int.self) else {
            return req.future(error: NotFound())
        }
        return DBListing.query(on: req)
            .filter(\.builderID == id)
            .filter(\.active > 0)
            .count()
    }

    func listings(_ req: Request) throws -> Future<[PublicListing]> {
        guard let id = try? req.parameters.next(Int.self) else {
            return req.future(error: NotFound())
        }
        return ListingController.listingQueryBuilder(with: req)
            .filter(\DBListing.builderID == id)
            .filter(\DBListing.active > 0)
            .all()
            .then({ (resultArray) -> EventLoopFuture<[PublicListing]> in
                return req.future(ListingController.publicListings(from: resultArray, request: req))
            })
    }
}

extension Request {
    var baseURL: URL {
        let hostname = http.headers.firstValue(name: .host)!
        var scheme = "https"
        if let sslDisabled = Environment.get("NHZ_SSL_DISABLED") {
            let sslDisabledString = NSString(string: sslDisabled)
            scheme = sslDisabledString.boolValue ? "http" : "https"
        }
        return URL(string: "\(scheme)://\(hostname)")!
    }
}
