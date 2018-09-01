//
//  CacheMiddleware.swift
//  App
//
//  Created by stephenciauri on 9/1/18.
//

import Foundation
import Vapor

final class CacheMiddleware: Middleware {
    let cacheDuration: TimeInterval
    
    init(duration: TimeInterval) {
        cacheDuration = duration
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        return try next.respond(to: request).flatMap({ (response) -> EventLoopFuture<Response> in
            var headerValue: String
            if self.cacheDuration <= 0 {
                headerValue = "no-cache"
            } else {
                headerValue = "max-age=\(Int(self.cacheDuration))"
            }
            response.http.headers.add(name: HTTPHeaderName.cacheControl, value: headerValue)
            return response.future(response)
        })
    }
}
