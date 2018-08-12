import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())

    /// Register routes to the router    
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    if let envHostname = Environment.get("NHZ_APP_HOSTNAME"),
        let envPort = Environment.get("NHZ_APP_PORT") {
        var serverConfig = NIOServerConfig.default()
        serverConfig.hostname = envHostname
        serverConfig.port = Int(envPort)!
        services.register(serverConfig)
    }

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // Configure a SQLite database
    let config = MySQLDatabaseConfig(hostname: Environment.get("NHZ_DB_HOSTNAME")!,
                                     port: Int(Environment.get("NHZ_DB_PORT")!)!,
                                     username: Environment.get("NHZ_DB_USERNAME")!,
                                     password: Environment.get("NHZ_DB_PASSWORD")!,
                                     database: Environment.get("NHZ_DB_SCHEMA")!,
                                     capabilities: MySQLCapabilities.default,
                                     characterSet: MySQLCharacterSet.latin1_swedish_ci,
                                     transport: MySQLTransportConfig.unverifiedTLS)
    
    let mysql = MySQLDatabase(config: config)

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: mysql, as: .mysql)
    services.register(databases)
    DBBuilder.defaultDatabase = DatabaseIdentifier(stringLiteral: Environment.get("NHZ_DB_SCHEMA")!)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: DBBuilder.self, database: .mysql)
    migrations.add(model: DBListing.self, database: .mysql)
    services.register(migrations)

}
