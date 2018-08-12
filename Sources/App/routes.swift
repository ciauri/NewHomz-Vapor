import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    
    let builderController = BuilderController()
    
    router.get("builders", use: builderController.index)
    router.get("builders", "featured", use: builderController.featured)
    router.get("builder", Int.parameter, use: builderController.withId)
    router.get("builder", Int.parameter, "listings", use: builderController.listings)


    
    let listingController = ListingController()
    
    router.get("listings", use: listingController.index)
    router.get("listings", "featured", use: listingController.featured)
    router.get("listings", "inRegion", use: listingController.map)
    router.get("listing", Int.parameter, use: listingController.withId)
    router.get("listing", Int.parameter, "gallery", use: listingController.gallery)
    router.get("listing", Int.parameter, "floorplans", use: listingController.floorplans)
}
