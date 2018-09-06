//
//  DBMasterPlan.swift
//  App
//
//  Created by stephenciauri on 9/5/18.
//

import Foundation
import Vapor
import FluentMySQL


final class DBMasterPlan: MySQLModel {
    static let entity = "masterplan"
    var id: Int?
    var name: String?
    var description: String?
    var lat: Double?
    var lng: Double?
    var builderId: Int?
    var pinURL: String?
    
    init(id: Int? = nil, name: String, description: String, lat: Double, lng: Double, builderId: Int, pinURL: String) {
        self.id = id
        self.name = name
        self.description = description
        self.lat = lat
        self.lng = lng
        self.builderId = builderId
        self.pinURL = pinURL
    }
    
    var builder: Parent<DBMasterPlan, DBBuilder>? {
        return parent(\.builderId)
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension DBMasterPlan: Migration {
    static func prepare(on conn: MySQLDatabase.Connection) -> Future<Void> {
        return conn.future()
    }
}
