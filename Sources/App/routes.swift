import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    try router.register(collection: EntryPointController())
    try router.register(collection: BuilderController())
    try router.register(collection: ListingController())
}
