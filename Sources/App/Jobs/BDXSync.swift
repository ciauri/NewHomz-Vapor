//
//  BDXSync.swift
//  App
//
//  Created by stephenciauri on 8/12/18.
//

import Foundation
import SWXMLHash
import Vapor


class BDXSync: Worker {
    let app: Application
    
    init(application: Application) {
        app = application
    }
 
    func sync() {
        app.eventLoop.scheduleRepeatedTask(initialDelay: TimeAmount.seconds(0), delay: TimeAmount.hours(24)) { (task) -> EventLoopFuture<Void> in
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            formatter.maximumFractionDigits = 2
            var builderData: [XMLIndexer] = []
            var parsedBuilders: [BDXBuilder] = []
            var dbConnection: DatabaseConnectable! = nil
            return self.fetchFeed()
                .then({ (data) -> EventLoopFuture<XMLIndexer> in
                    let promise = self.next().newPromise(XMLIndexer.self)
                    let xml = SWXMLHash.parse(data)
                    promise.succeed(result: xml)
                    return promise.futureResult
                }).then({ (xml) -> EventLoopFuture<[BDXBuilder]> in
                    let promise = self.next().newPromise([BDXBuilder].self)
                    builderData = xml["Builders"]["Corporation"]["Builder"].all
                    parsedBuilders = builderData.compactMap{BDXBuilder(withIndexer: $0)}
                    promise.succeed(result: parsedBuilders)
                    return promise.futureResult
                }).then({_ -> EventLoopFuture<Void> in
                    let builderCount = builderData.count
                    let builders: [BDXBuilder] = builderData.compactMap{BDXBuilder(withIndexer: $0)}
                    
                    let listingCount: Int = builderData.map({$0["Subdivision"].all.count}).reduce(0, +)
                    let listingsParsed: Int = builders.map({$0.subdivisions.count}).reduce(0, +)
                    
                    print("Builder success: \(formatter.string(from: (Float(builders.count)/Float(builderCount)) as NSNumber) ?? "wut")")
                    print("Subdivision success: \(formatter.string(from: (Float(listingsParsed)/Float(listingCount)) as NSNumber) ?? "wut")")
                    
                    let promise = self.next().newPromise(Void.self)
                    promise.succeed()
                    return promise.futureResult
                }).then({ (_) -> EventLoopFuture<[DBBuilder]> in
                    return self.app.newConnection(to: DBBuilder.defaultDatabase!).then({ (connection) -> EventLoopFuture<[DBBuilder]> in
                        dbConnection = connection
                        return DBBuilder.query(on: connection).all()
                    })
                }).then({ (builders) -> EventLoopFuture<[Int:DBBuilder]> in
                    let buildersToUpdate = Dictionary(uniqueKeysWithValues: builders
                        .filter({$0.feedID != nil})
                        .map({($0.feedHash, $0)}))
                    let buildersToAdd: [BDXBuilder] = parsedBuilders.filter({ buildersToUpdate[$0.feedHash] == nil})
                    return self.insertNewBuilders(newBuilders: buildersToAdd, dbConnection: dbConnection)
                        .map({buildersToUpdate})
                }).map({ builders in
                    return self.updateBuilders(toUpdate: builders, with: parsedBuilders, dbConnection: dbConnection)
                })
        }
    }
    
    private func insertNewBuilders(newBuilders: [BDXBuilder], dbConnection: DatabaseConnectable) -> EventLoopFuture<Void> {
        print("Inserting \(newBuilders.count) new builders")
        let futures: [EventLoopFuture<Void>] = newBuilders.map { (bdxBuilder) -> EventLoopFuture<Void> in
            return bdxBuilder.toDbBuilder.create(on: dbConnection).map({ (dbBuilder) -> ((BDXBuilder, DBBuilder)) in
                return (bdxBuilder,dbBuilder)
            }).then({ (result) -> EventLoopFuture<Void> in
                print("Inserting \(result.0.subdivisions.count) subs for \(result.0.name)")
                let futures: [EventLoopFuture<Void>] = result.0.subdivisions.map({ subdivision -> EventLoopFuture<Void> in
                    return self.insertNewListing(with: subdivision, builder: result.1, dbConnection: dbConnection)
                })
                return EventLoopFuture<Void>.andAll(futures, eventLoop: self.future().eventLoop)
            })
        }
        return EventLoopFuture<Void>.andAll(futures, eventLoop: self.future().eventLoop)
    }
    
    private func insertNewListing(with sub: BDXSubdivision, builder: DBBuilder, dbConnection: DatabaseConnectable) -> EventLoopFuture<Void> {
        return sub.toDbListing(with: builder.id!).create(on: dbConnection).then({ (listing) -> EventLoopFuture<Void> in
            if let images = sub.images {
                print("Inserting \(images.count) images for \(sub.name)")
                let futures = images.map({self.insertNewImage(with: $0, listing: listing, dbConnection: dbConnection)})
                return EventLoopFuture<Void>.andAll(futures, eventLoop: self.future().eventLoop)
            } else {
                return self.future()
            }
        })
    }
    
    private func insertNewImage(with image: BDXImage, listing: DBListing, dbConnection: DatabaseConnectable) -> EventLoopFuture<Void> {
        return DBGalleryImage(cID: listing.id!,
                              caption: image.caption ?? "",
                              photo: image.url.absoluteString,
                              showOrder: image.position)
            .create(on: dbConnection)
            .catch({ (error) in
                print(error.localizedDescription)
            }).then({ (image) -> EventLoopFuture<Void> in
                return self.future()
            })
        
    }
    
    private func updateBuilders(toUpdate builderMap: [Int:DBBuilder], with feedBuilders: [BDXBuilder], dbConnection: DatabaseConnectable) -> EventLoopFuture<Void> {
        let toUpdate = feedBuilders.filter({ builderMap[$0.feedHash] != nil })
        print("Updating \(toUpdate.count) builders")
        return EventLoopFuture<Void>.andAll(toUpdate.compactMap { (builder) -> EventLoopFuture<Void> in
            if let dbBuilder = builderMap[builder.feedHash] {
                var future: EventLoopFuture<[DBListing]>!
                if dbBuilder.hasUpdates(from: builder) {
                    dbBuilder.update(with: builder)
                    future = dbBuilder.update(on: dbConnection).then({ (try? $0.listings.query(on: dbConnection).all()) ?? self.next().future([]) })
                } else {
                    future = (try? dbBuilder.listings.query(on: dbConnection).all()) ?? self.next().future([])
                }
                return future.then({ (listings) -> EventLoopFuture<Void> in
                    return self.updateListings(toUpdate: listings, for: dbBuilder, with: builder.subdivisions, dbConnection: dbConnection)
                })
            } else {
                return next().future()
            }
        }, eventLoop: next())
    }
    
    private func updateListings(toUpdate listings: [DBListing], for builder: DBBuilder, with feedListings: [BDXSubdivision], dbConnection: DatabaseConnectable) -> EventLoopFuture<Void> {
        let bdxListingMap = Dictionary(uniqueKeysWithValues: feedListings.map({($0.feedHash, $0)}))
        let dbListingMap = Dictionary(uniqueKeysWithValues: listings.map({($0.feedHash, $0)}))
        let toDelete = listings.filter({ bdxListingMap[$0.feedHash] == nil })
        let toUpdate = listings.filter({ bdxListingMap[$0.feedHash] != nil })
        let toAdd = feedListings.filter({ dbListingMap[$0.feedHash] == nil })
        print("Updating \(toUpdate.count) listings for \(builder.builder)")
        return EventLoopFuture<Void>.andAll(toUpdate.compactMap({ (listing) -> EventLoopFuture<Void> in
            let bdxListing = bdxListingMap[listing.feedHash]!
            if listing.hasUpdates(from: bdxListing) {
                listing.update(from: bdxListing)
                return listing.update(on: dbConnection).map({_ in})
            } else {
                return future()
            }
        }), eventLoop: next())
            .then({ (_) -> EventLoopFuture<Void> in
            print("Deleting \(toDelete.count) listings for \(builder.builder)")
            return EventLoopFuture<Void>.andAll(toDelete.compactMap({$0.delete(on: dbConnection)}),
                                         eventLoop: self.eventLoop)
            }).then({ (_) -> EventLoopFuture<Void> in
                print("Adding \(toAdd.count) listings for \(builder.builder)")
                return EventLoopFuture<Void>.andAll(toAdd.compactMap({self.insertNewListing(with: $0, builder: builder, dbConnection: dbConnection)}),
                                                    eventLoop: self.eventLoop)
            })
    }
    
    
    
    private func fetchFeed() -> Future<Data>  {
        let promise = next().newPromise(Data.self)
        guard let url = Environment.get("NHZ_FEED_URL")?.toURL else {
            promise.fail(error: NotFound())
            return promise.futureResult
        }
        
        HTTPClient.connect(hostname: url.host!, on: self).then { (client) -> EventLoopFuture<HTTPResponse> in
            let request = HTTPRequest(method: .GET, url: url)
            return client.send(request)
            }.then { (response) -> EventLoopFuture<Void> in
                promise.succeed(result: response.body.data!)
                return self.future()
        }
        return promise.futureResult
    }
    
    private func queryBuilders(on application: Application) -> Future<[DBBuilder]> {
        return application.newConnection(to: DBBuilder.defaultDatabase!).then({ (connection) -> EventLoopFuture<[DBBuilder]> in
            return DBBuilder.query(on: connection).all()
        })
    }
    
    
    func shutdownGracefully(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void) {
        
    }
    
    func next() -> EventLoop {
        return app.eventLoop
    }

}
