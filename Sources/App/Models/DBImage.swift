//
//  DBImage.swift
//  App
//
//  Created by stephenciauri on 8/12/18.
//

import Vapor
import FluentMySQL


final class DBGalleryImage: MySQLModel {
    static let entity = "gallery"
    var id: Int?
    var cID: Int
    var caption: String
    var photo: String
    var showOrder: Int
    
    init(id: Int? = nil, cID: Int, caption: String, photo: String, showOrder: Int) {
        self.id = id
        self.cID = cID
        self.caption = caption
        self.photo = photo
        self.showOrder = showOrder
    }
}


extension DBGalleryImage {
    var listing: Parent<DBGalleryImage, DBListing> {
        return parent(\.cID)
    }
}


extension DBGalleryImage: Migration {
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        return conn.future()
    }
}

extension DBGalleryImage: Content { }
extension DBGalleryImage: Parameter { }


final class DBFloorplanImage: MySQLModel {
    static let entity = "floorplans"
    var id: Int?
    var cID: Int
    var caption: String
    var photo: String
    var showOrder: Int
    
    init(id: Int? = nil, cID: Int, caption: String, photo: String, showOrder: Int) {
        self.id = id
        self.cID = cID
        self.caption = caption
        self.photo = photo
        self.showOrder = showOrder
    }
}


extension DBFloorplanImage {
    var listing: Parent<DBFloorplanImage, DBListing> {
        return parent(\.cID)
    }
}


extension DBFloorplanImage: Migration {
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        return conn.future()
    }
}

extension DBFloorplanImage: Content { }
extension DBFloorplanImage: Parameter { }
