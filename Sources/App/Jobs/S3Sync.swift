//
//  S3Sync.swift
//  App
//
//  Created by stephenciauri on 11/14/18.
//

import Foundation
import Vapor
import S3


class S3Sync: Worker {
    let app: Application
    let logger: Logger?
    
    init(application: Application) {
        app = application
        logger = try? application.make(Logger.self)
    }
    
    func sync() throws {
        let logger = self.logger
        logger?.info("Scheduling s3 sync task...")
        let request = Request(using: app)
        request.http.headers.add(name: .host, value: "api.newhomz.com")
        let s3 = try request.makeS3Client()
        
        next().scheduleRepeatedTask(initialDelay: TimeAmount.seconds(0), delay: TimeAmount.hours(24)) { (task) -> EventLoopFuture<Void> in
            do {
                return try ListingController().index(request).then({ (fetched) -> EventLoopFuture<Void> in
                    do {
                        let encoder = JSONEncoder()
                        let json = try encoder.encode(fetched)
                        let jsonString = String(data: json, encoding: .utf8) ?? ""
                        return try s3.put(string: jsonString, mime: MediaType.json, destination: "listingIndex.json", access: .publicRead, on: request).then({ (response) -> EventLoopFuture<Void> in
                            logger?.debug("\(response)")
                            return self.future()
                        })
                    } catch {
                        logger?.error(error.localizedDescription)
                        return self.future()
                    }
                })
            } catch {
                logger?.error(error.localizedDescription)
                return self.future()
            }
        }
    }
    
    func shutdownGracefully(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void) {
        
    }
    
    func next() -> EventLoop {
        return app.eventLoop
    }
}
