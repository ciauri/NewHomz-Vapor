//
//  Builder.swift
//  App
//
//  Created by stephenciauri on 8/11/18.
//

import Vapor
import FluentMySQL


final class DBBuilder: MySQLModel {
    static let entity = "builders"
    var id: Int?
    var builder: String
    var phone: String
    var fax: String
    var email: String
    var paid: Bool
    var photo: String?
    var website: String?
    var status: String
    var ads_enabled: Bool
    var feedID: String?
    var sourceID: String?

    init(id: Int? = nil, builder: String, phone: String, fax: String, email: String, paid: Bool, photo: String?, website: String?, status: String, ads_enabled: Bool, feedID: String, sourceID: String) {
        self.id = id
        self.builder = builder
        self.phone = phone
        self.fax = fax
        self.email = email
        self.paid = paid
        self.photo = photo
        self.website = website
        self.status = status
        self.ads_enabled = ads_enabled
        self.feedID = feedID
        self.sourceID = sourceID
    }
}

extension BDXBuilder {
    var toDbBuilder: DBBuilder {
        return DBBuilder(builder: name, phone: "", fax: "", email: defaultLeadsEmail ?? "", paid: false, photo: logoURL?.absoluteString, website: website?.absoluteString, status: "ACTIVE", ads_enabled: true, feedID: "newhomefeed", sourceID: id)
    }
}

extension DBBuilder {
    func hasUpdates(from feedBuilder: BDXBuilder) -> Bool {
        return builder != feedBuilder.name ||
            email != feedBuilder.defaultLeadsEmail ?? "" ||
            photo != feedBuilder.logoURL?.absoluteString ||
            website != feedBuilder.website?.absoluteString
    }
    
    func update(with feedBuilder: BDXBuilder) {
        builder = feedBuilder.name
        email = feedBuilder.defaultLeadsEmail ?? ""
        photo = feedBuilder.logoURL?.absoluteString
        website = feedBuilder.website?.absoluteString
    }
}


extension DBBuilder {
    var listings: Children<DBBuilder, DBListing> {
        return children(\.builderID)
    }
}

extension DBBuilder {
    var feedHash: Int {
        return "\(sourceID ?? "")\(builder)".hashValue
    }
}


/// Allows `Todo` to be used as a dynamic migration.
extension DBBuilder: Migration {
    static func prepare(on conn: Database.Connection) -> Future<Void> {
        return conn.future()
    }
}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension DBBuilder: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension DBBuilder: Parameter { }

extension DBBuilder: Hashable {
    var hashValue: Int {
        return id ?? 0
    }
    
    static func == (lhs: DBBuilder, rhs: DBBuilder) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    /* Uncomment and replace when swift 4.2 happens
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
     */
}
