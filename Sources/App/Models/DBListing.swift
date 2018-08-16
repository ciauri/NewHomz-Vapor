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
    var sourceID: String?
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
    
    init(id: Int? = nil, listing: String, builderID: Int, active: Int, city: String, county: String, state: String, zip: Int, description: String, email: String, phone: String, priceTxt: String, priceLow: Int, priceHigh: Int, sqftLow: Int, sqftHigh: Int, bedLow: Int, bedHigh: Int, bathLow: Float, bathHigh: Float, hoa: Int, tax: Int, payment: Int, lot: Int, lat: Double, lng: Double, vid: String, photo: String, photo2: String, website: String, masterplanId: Int, status: String, schoolDistrictName: String, propType: String, sourceID: String) {
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
        self.sourceID = sourceID
    }
}

extension BDXSubdivision {
    func toDbListing(with builderID: Int) -> DBListing {
        let addressToUse = address ?? salesOffice.address
        return DBListing(listing: name,
                         builderID: builderID,
                         active: 1,
                         city: addressToUse.city,
                         county: addressToUse.county ?? "",
                         state: addressToUse.state,
                         zip: Int(addressToUse.postalCode) ?? 0,
                         description: description ?? "",
                         email: email ?? "",
                         phone: salesOffice.phone?.phoneString ?? "",
                         priceTxt: "From the",
                         priceLow: Int(priceLow ?? 0),
                         priceHigh: Int(priceHigh ?? 0),
                         sqftLow: squareFeetLow ?? 0,
                         sqftHigh: squareFeetHigh ?? 0,
                         bedLow: plans?.reduce(0, {min($0, $1.bedrooms)}) ?? 0,
                         bedHigh: plans?.reduce(0, {max($0, $1.bedrooms)}) ?? 0,
                         bathLow: Float(plans?.reduce(0, {min($0, $1.bathrooms)}) ?? 0),
                         bathHigh: Float(plans?.reduce(0, {max($0, $1.bathrooms)}) ?? 0),
                         hoa: 0, tax: 0, payment: 0,
                         lot: 0,
                         lat: addressToUse.geocode?.latitude.nhzRounded ?? 0, lng: addressToUse.geocode?.longitude.nhzRounded ?? 0,
                         vid: "", photo: images?.first(where: {$0.isPreferred})?.url.absoluteString ?? "", photo2: "",
                         website: plans?.first?.website ?? "",
                         masterplanId: 0,
                         status: status.rawValue,
                         schoolDistrictName: schools?.first?.districtName ?? "",
                         propType: plans?.first?.type.rawValue ?? "",
                         sourceID: id)
    }
}

extension DBListing {
    func hasUpdates(from feedSub: BDXSubdivision) -> Bool {
        let addressToUse = feedSub.address ?? feedSub.salesOffice.address
        let differentName = listing != feedSub.name
        let differentCity = city != addressToUse.city
        let differentCounty = county != addressToUse.county ?? ""
        let differentState = state != addressToUse.state
        let differentZip = zip != (Int(addressToUse.postalCode) ?? 0)
        let differentDescription = description != feedSub.description
        let differentEmail = email != feedSub.email
        let differentPhone = phone != feedSub.salesOffice.phone?.phoneString ?? ""
        let differentPriceLow = priceLow != Int(feedSub.priceLow ?? 0)
        let differentPriceHigh = priceHigh != Int(feedSub.priceHigh ?? 0)
        let differentSizeLow = sqftLow != feedSub.squareFeetLow ?? 0
        let differentSizeHigh = sqftHigh != feedSub.squareFeetHigh ?? 0
        let differentBedLow = bedLow != feedSub.plans?.first?.bedrooms ?? 0
        let differentBedHigh = bedHigh != feedSub.plans?.first?.bedrooms ?? 0
        let differentBathLow = bathLow != Float(feedSub.plans?.first?.bathrooms ?? 0)
        let differentBathHigh = bathHigh != Float(feedSub.plans?.first?.bathrooms ?? 0)
        let differentLat = lat != addressToUse.geocode?.latitude.nhzRounded ?? 0
        let differentLng = lng != addressToUse.geocode?.longitude.nhzRounded ?? 0
        let differentPhoto = photo != feedSub.images?.first?.url.absoluteString ?? ""
        let differentWebsite = website != feedSub.plans?.first?.website ?? ""
        let differentStatus = status != feedSub.status.rawValue
        let differentSchoolDistrictName = schoolDistrictName != feedSub.schools?.first?.districtName ?? ""
        let differentPropType = propType != feedSub.plans?.first?.type.rawValue ?? ""
        
        return differentName || differentCity || differentCounty || differentState || differentZip || differentDescription || differentEmail || differentPhone || differentPriceLow || differentPriceHigh || differentSizeLow || differentSizeHigh || differentBedLow || differentBedHigh || differentBathLow || differentBathHigh || differentLat || differentLng || differentPhoto || differentWebsite || differentStatus || differentSchoolDistrictName || differentPropType
    }
    
    func update(from feedSub: BDXSubdivision) {
        let addressToUse = feedSub.address ?? feedSub.salesOffice.address
        listing = feedSub.name
        city = addressToUse.city
        county = addressToUse.county ?? ""
        state = addressToUse.state
        zip = (Int(addressToUse.postalCode) ?? 0)
        lat = addressToUse.geocode?.latitude.nhzRounded ?? 0
        lng = addressToUse.geocode?.longitude.nhzRounded ?? 0
        description = feedSub.description ?? ""
        email = feedSub.email ?? ""
        phone = feedSub.salesOffice.phone?.phoneString ?? ""
        priceLow = Int(feedSub.priceLow ?? 0)
        priceHigh = Int(feedSub.priceHigh ?? 0)
        sqftLow = feedSub.squareFeetLow ?? 0
        sqftHigh = feedSub.squareFeetHigh ?? 0
        bedLow = feedSub.plans?.first?.bedrooms ?? 0
        bedHigh = feedSub.plans?.first?.bedrooms ?? 0
        bathLow = Float(feedSub.plans?.first?.bathrooms ?? 0)
        bathHigh = Float(feedSub.plans?.first?.bathrooms ?? 0)
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
    
    var feedHash: Int {
        return "\(sourceID ?? "")\(listing)".hashValue
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

extension Double {
    var nhzRounded: Double? {
        return Double(String(format: "%.8f", self))
    }
}
