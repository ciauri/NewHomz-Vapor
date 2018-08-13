import Vapor

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    let sync = BDXSync(application: app)
    sync.sync()
}
