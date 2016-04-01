#if os(Linux)
import Glibc
#endif

import Vapor
import VaporZewoMustache
import Redbird

// Bootstrap Redis
public var redis: Redbird

do {
    let config = RedbirdConfig(address: "127.0.0.1", port: 6379)
    redis = try Redbird(config: config)
    print("Redis connected")
} catch {
    print("Redis error: \(error)")
}

let app = Application()

let linkController = LinkController(application: app)
let userController = UserController(application: app)

app.middleware(AuthMiddleware.self) {
   // articles / links
   app.get("/", handler: linkController.index)
   app.get("/submit", handler: linkController.add)
   app.post("/api/submit", handler: linkController.add)

   // user management
   app.get("/login", handler: userController.login)
   app.get("/register", handler: userController.register)
   app.post("/api/login", handler: userController.login)
   app.post("/api/register", handler: userController.register)
}


//Add includeable files to the Mustache provider
VaporZewoMustache.Provider.includeFiles["header"] = "Includes/header.mustache"
VaporZewoMustache.Provider.includeFiles["head"] = "Includes/head.mustache"
VaporZewoMustache.Provider.includeFiles["layout"] = "layout.mustache"

app.providers.append(VaporZewoMustache.Provider)

// Print what link to visit for default port
print("Visit http://localhost:8080")
app.start(port: 8080)
