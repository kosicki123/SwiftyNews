import Vapor
import Redbird
import Foundation

class UserController: Controller {
    required init(application: Application) {
        Log.info("User controller created")
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return Json([
            "controller": "UserController.index"
        ])
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        return Json([
            "controller": "UserController.store"
        ])
    }
    
    /**
    	Since item is of type User, 
    	only instances of user will be received
    */
    func show(request: Request, item user: User) throws -> ResponseRepresentable {
        //User can be used like JSON with JsonRepresentable
        return Json([
            "controller": "UserController.show",
            "user": user
        ])
    }
    
    func update(request: Request, item user: User) throws -> ResponseRepresentable {
        //User is JsonRepresentable
        return user.makeJson()
    }
    
    func destroy(request: Request, item user: User) throws -> ResponseRepresentable {
        //User is ResponseRepresentable by proxy of JsonRepresentable
        return user
    }

    /// Login
    func login(request: Request) throws -> ResponseRepresentable {
        // Perform login action
        if request.method == .Post {
            guard let username = request.data["username"]?.string else {
                return Json(["status": "err", "message": "Username is a required field."])
            }

            guard let password = request.data["password"]?.string else {
                return Json(["status": "err", "message": "Password is a required field."])
            }

            if let (auth, apisecret) = try checkUserCredentials(username, password: password) {
                return Json(["status": "ok", "auth": auth, "apisecret": apisecret])
            }

            return Json(["status": "err", "message": "No match for the specified username / password pair."])
        } 

        return try app.view("login.mustache", context: ["params": request.parameters])
    }

    /// Register
    func register(request: Request) throws -> ResponseRepresentable {
        // Perform registration action
        if request.method == .Post {
            guard let username = request.data["username"]?.string else {
                return Json(["status": "err", "message": "Username is a required field."])
            }

            guard let password = request.data["password"]?.string else {
                return Json(["status": "err", "message": "Password is a required field."])
            }

            guard let email = request.data["email"]?.string else {
                return Json(["status": "err", "message": "The e-mail is a required field."])
            }
            let (authToken, apisecret, error) = try createUser(username, password: password, email: email)
            if let e = error {
                print("registration error -> \(e)")
                return Json(["status": "err", "message": e])
            }

            return Json(["status": "ok", "auth": authToken!, "apisecret": apisecret!])
        } 

        return try app.view("login.mustache", context: ["params": request.parameters, "showEmail": true])
    }

    // Actions
    private func createUser(username: String, password: String, email:String) throws -> (String?, String?, String?) {
        if try redis.exists("email.to.id:\(email.lowercaseString)") {
            return (nil, nil, "Email already used, please recover the password if you can't login.")
        }

        if try redis.exists("username.to.id:\(username.lowercaseString)") {
            return (nil, nil, "Username is already taken, please try a different one.")
        }

        // if rate_limit_by_ip(UserCreationDelay,"create_user",request.ip) {
        //     return nil, nil, "Please wait some time before creating a new user."
        // }

        let id = try redis.incr("users.count")
        let authToken = randomStringWithLength(32)
        let apisecret = randomStringWithLength(32)
        let salt = randomStringWithLength(32)
        let time = "\(Int(NSDate().timeIntervalSince1970))"

        try redis.hmset("user:\(id)", [
            "id": "\(id)",
            "username": username,
            "salt": salt,
            "password": hashPassword(password, salt: salt),
            "ctime": time,
            "karma": "1", //registration gives 1 karma point
            "about": "",
            "email": email,
            "auth": authToken,
            "apisecret": apisecret,
            "flags": "",
            "karma_incr_time": time])

        try redis.set("username.to.id:\(username.lowercaseString)", "\(id)")
        try redis.set("email.to.id:\(email.lowercaseString)", "\(id)")
        try redis.set("auth:\(authToken)", "\(id)")

        // First user ever created (id = 1) is an admin
        if id == 1 {
           try redis.hmset("user:\(id)", ["flags": "a"])  
        }
        
        return (authToken, apisecret, nil)
    }

    /// Temporary here, has to be moved away
    private func randomStringWithLength(len : Int) -> String {
        let charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var c = Array(charSet.characters)
        var s: String = ""
        for _ in (1...len) {
            s.append(c[Int(arc4random()) % c.count])
        }
        return s
    }

    /// TODO: Use hash algorithm working in Swift and Linux
    private func hashPassword(password: String, salt: String) -> String {
        return "\(password)-\(salt)"
    }

    private func getUserById(id: String) throws -> [String:String] {
        return try redis.hgetall("user:\(id)")
    }

    private func getUserByUsername(username: String) throws -> [String:String]? {
        guard try redis.exists("username.to.id:\(username.lowercaseString)") else {
            return nil
        }

        let id = try redis.get("username.to.id:\(username.lowercaseString)")
        return try getUserById(id)
    }

    private func checkUserCredentials(username: String, password: String) throws -> (String, String)? {
        guard let user = try getUserByUsername(username) else {
            return nil
        }
        let hashed = hashPassword(password, salt: user["salt"]!)
        if user["password"]! == hashed {
            return (user["auth"]!, user["apisecret"]!)
        }
        return nil
    }
    
}