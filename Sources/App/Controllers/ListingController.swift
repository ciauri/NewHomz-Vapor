//
//  ListingController.swift
//  App
//
//  Created by stephenciauri on 8/11/18.
//

import Foundation
import Vapor
import FluentMySQL


final class ListingController: RouteCollection {
    func boot(router: Router) throws {
        router.grouped(CacheMiddleware(duration: 86400)).get("listings", use: index)
        router.get("listings", "featured", use: featured)
        router.get("listings", "inRegion", use: map)
        router.get("listings", "count", use: count)
        router.get("listing", use: withId)
        router.get("listing", Int.parameter, use: withId)
        router.get("listing", Int.parameter, "gallery", use: gallery)
        router.get("listing", Int.parameter, "floorplans", use: floorplans)
    }

    // MARK: - Handlers
    func index(_ req: Request) throws -> Future<[PublicListing]> {
        if let offset = try? req.query.get(Int.self, at: "offset") {
            return try indexWithOffset(req, offset: offset)
        } else {
            return ListingController.listingQueryBuilder(with: req)
                .filter(\DBListing.active > 0)
                .all()
                .then({ (resultArray) -> EventLoopFuture<[PublicListing]> in
                    return req.future(ListingController.publicListings(from: resultArray, request: req))
                })
        }
    }
    
    func indexWithOffset(_ req: Request, offset: Int) throws -> Future<[PublicListing]> {
        guard offset > 0 else {
            return req.future([])
        }
        return ListingController.listingQueryBuilder(with: req)
            .filter(\DBListing.active > 0)
            .range(lower: offset, upper: offset + 100)
            .all()
            .then({ (resultArray) -> EventLoopFuture<[PublicListing]> in
                return req.future(ListingController.publicListings(from: resultArray, request: req))
            })
    }
    
    func featured(_ req: Request) throws -> Future<[PublicListing]> {
        return ListingController.listingQueryBuilder(with: req)
            .filter(\DBListing.active > 1)
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
        return ListingController.listingQueryBuilder(with: req)
            .filter(\DBListing.active > 0)
            .filter(\DBListing.lat >= latStart)
            .filter(\DBListing.lat <= latStop)
            .filter(\DBListing.lng >= lonStart)
            .filter(\DBListing.lng <= lonStop)
            .all()
            .then({ (resultArray) -> EventLoopFuture<[PublicListing]> in
                return req.future(ListingController.publicListings(from: resultArray, request: req))
            }).then({
                return ListingController.getMasterplanBuilders(for: $0, with: req)
            })
    }
    
    func withId(_ req: Request) throws -> Future<PublicListing> {
        guard let id = (try? req.parameters.next(Int.self)) ?? (try? req.query.get(Int.self, at: "id")) else {
            return req.future(error: NotFound())
        }
        return ListingController.listingQueryBuilder(with: req)
            .filter(\DBListing.id == id)
            .all()
            .then({ (resultArray) -> EventLoopFuture<PublicListing?> in
                return req.future(ListingController.publicListings(from: resultArray, request: req).first)
            }).unwrap(or: NotFound())
    }
    
    func count(_ req: Request) throws -> Future<Int> {
        return DBListing.query(on: req)
            .filter(\.active > 0)
            .count()
    }
    
    func gallery(_ req: Request) throws -> Future<[PublicGalleryImage]> {
        guard let id = try? req.parameters.next(Int.self) else {
            return req.future(error: NotFound())
        }
        return DBGalleryImage.query(on: req)
            .filter(\.cID == id)
            .all().then({ (resultArray) -> EventLoopFuture<[PublicGalleryImage]?> in
                return req.future(ListingController.publicGallery(from: resultArray))
            }).unwrap(or: NotFound())
    }
    
    func floorplans(_ req: Request) throws -> Future<[DBFloorplanImage]> {
        guard let id = try? req.parameters.next(Int.self) else {
            return req.future(error: NotFound())
        }
        return DBFloorplanImage.query(on: req)
            .filter(\.cID == id)
            .all()
    }
    
    static func listingQueryBuilder(with request: Request) -> QueryBuilder<MySQLDatabase, ((DBListing, DBBuilder), DBMasterPlan )> {
        return DBListing.query(on: request)
            .join(\DBBuilder.id, to: \DBListing.builderID)
            .join(\DBMasterPlan.id, to: \DBListing.masterplanId, method: .left)
            .alsoDecode(DBBuilder.self)
            .alsoDecode(DBMasterPlan.self)
    }
    
    static func getMasterplanBuilders(for listings: [PublicListing], with request: Request) -> EventLoopFuture<[PublicListing]> {
        let futures = listings.map { (listing) -> EventLoopFuture<PublicListing> in
            if let masterPlan = listing.masterPlan {
                return DBBuilder.find(masterPlan.builderID!, on: request)
                    .then({ (builder) -> EventLoopFuture<PublicListing> in
                        var mutableListing = listing
                        mutableListing.masterPlan?.thumbnail = builder?.photo
                        return request.future(mutableListing)
                })
            } else {
                return request.future(listing)
            }
        }

        let promise = request.eventLoop.newPromise([PublicListing].self)
        let folded = promise.futureResult.fold(futures) { (listingArray, dunno) -> EventLoopFuture<[PublicListing]> in
            return request.eventLoop.future(listingArray+[dunno])
        }
        promise.succeed(result: [])
        return folded
    }

    
    static func publicListings(from results: [((DBListing, DBBuilder), DBMasterPlan)], request: Request) -> [PublicListing] {
        let builderCache = createBuilderCache(from: results, request: request)
        return results.map({ (result) -> PublicListing in
            let masterPlan = (result.1.id ?? 0) > 0 ? result.1.publicMasterPlan : nil
            let listing = result.0.0.publicListing(with: builderCache[result.0.0.builderID]!, masterPlan: masterPlan, request: request)
            return listing
        })
    }
    static func createBuilderCache(from results: [((DBListing, DBBuilder), DBMasterPlan)], request: Request) -> [Int: PublicBuilder] {
        var cache: [Int:PublicBuilder] = [:]
        for result in results {
            let dbBuilder = result.0.1
            guard let builderID = dbBuilder.id else {
                continue
            }
            if cache[builderID] == nil {
                cache[builderID] = dbBuilder.publicBuilder(with: request)
            }
        }
        return cache
    }
    
    static func publicGallery(from results: [DBGalleryImage]) -> [PublicGalleryImage] {
        return results.map({ $0.toPublicImage })
    }
}
