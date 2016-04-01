#if os(Linux)
import Glibc
#endif

import Vapor
import Redbird

class AuthMiddleware: Middleware {

	class func handle(handler: Request.Handler, for application: Application) -> Request.Handler {
		return { request in
			// You can manipulate the request before calling the handler
			// and abort early if necessary, a good injection point for
			// handling auth.
			
			if let _ = request.parameters["userId"] {
				request.parameters.removeValue(forKey: "userId")
			}

			if let auth = request.cookies["auth"] where try redis.exists("auth:\(auth)")  {
				let userId = try redis.get("auth:\(auth)") 
				let user = try redis.hgetall("user:\(userId)")
				if let username = user["username"], let karma = user["karma"], let apisecret = user["apisecret"]  {
					request.parameters["username"] = username
					request.parameters["userId"] = userId
					request.parameters["karma"] = karma
					request.parameters["apisecret"] = apisecret
				}
			}
			

			let response = try handler(request: request)

			// You can also manipulate the response to add headers
			// cookies, etc.

			return response
		}
	}

}
