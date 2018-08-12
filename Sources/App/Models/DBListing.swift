//
//  Listing.swift
//  App
//
//  Created by stephenciauri on 8/11/18.
//

import Vapor
import FluentMySQL


final class DBListing: MySQLModel {
    static let entity = "listings"
    var id: Int?
    var builderID: Int
    var listing: String
    var propType: String
    var active: Int
    var city: String
    var county: String
    var state: String
    var zip: Int
    var description: String
    var email: String
    var phone: String
    var priceTxt: String
    var priceLow: Int
    var priceHigh: Int
    var sqftLow: Int
    var sqftHigh: Int
    var bedLow: Int
    var bedHigh: Int
    var bathLow: Float
    var bathHigh: Float
    var hoa: Int
    var tax: Int
    var payment: Int
    var lot: Int
    var lat: Double
    var lng: Double
    var vid: String
    var photo: String
    var photo2: String
    var website: String
    var masterplanId: Int?
    var status: String
    var schoolDistrictName: String
    
    init(id: Int? = nil, listing: String, builderID: Int, active: Int, city: String, county: String, state: String, zip: Int, description: String, email: String, phone: String, priceTxt: String, priceLow: Int, priceHigh: Int, sqftLow: Int, sqftHigh: Int, bedLow: Int, bedHigh: Int, bathLow: Float, bathHigh: Float, hoa: Int, tax: Int, payment: Int, lot: Int, lat: Double, lng: Double, vid: String, photo: String, photo2: String, website: String, masterplanId: Int, status: String, schoolDistrictName: String, propType: String) {
        self.id = id
        self.builderID = builderID
        self.listing = listing
        self.active = active
        self.city = city
        self.county=county
        self.state=state
        self.zip=zip
        self.description=description
        self.email=email
        self.phone=phone
        self.priceTxt=priceTxt
        self.priceLow=priceLow
        self.priceHigh=priceHigh
        self.sqftLow=sqftLow
        self.sqftHigh=sqftHigh
        self.bedLow=bedLow
        self.bedHigh=bedHigh
        self.bathLow=bathLow
        self.bathHigh=bathHigh
        self.hoa=hoa
        self.tax=tax
        self.payment=payment
        self.lot=lot
        self.lat=lat
        self.lng=lng
        self.vid=vid
        self.photo=photo
        self.photo2=photo2
        self.website=website
        self.masterplanId=masterplanId
        self.status=status
        self.schoolDistrictName=schoolDistrictName
        self.propType = propType
    }
}

extension DBListing {
    var builder: Parent<DBListing, DBBuilder> {
        return parent(\.builderID)
    }
    
    var gallery: Children<DBListing, DBGalleryImage> {
        return children(\.cID)
    }
    
    var floorplans: Children<DBListing, DBFloorplanImage> {
        return children(\.cID)
    }
}

extension DBListing: Migration {
    static func prepare(on conn: MySQLConnection) -> Future<Void> {
        return conn.future()
    }
}
/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension DBListing: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension DBListing: Parameter { }
