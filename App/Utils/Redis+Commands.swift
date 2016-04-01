import Redbird
import Foundation

extension Redbird {
    
    func incr(key: String) throws -> Int {
        return try command("INCR", params: [key]).toInt()
    }

    func exists(key: String) throws -> Bool {
        return try command("EXISTS", params: [key]).toBool()
    }

    func set(key: String, _ value: String) throws -> Bool {
        return try command("SET", params: [key, value]).toString() == "OK"
    }

    func get(key: String) throws -> String {
        return try command("GET", params: [key]).toString()
    }

    func hget(set: String, key: String) throws -> String {
        return try command("HGET", params: [set, key]).toString()
    }

    func hgetall(key: String) throws -> [String: String] {
        let result = try command("HGETALL", params: [key]).toArray().map({ try $0.toString() })
        var hash = [String:String]()
        var key: String? = nil
        var val: String? = nil
        for item in result {
            if key == nil {
                key = item
            } else if val == nil {
                val = item
            } else {
                hash[key!] = val!
                key = item
                val = nil
            }
        } 
        hash[key!] = val! // setting last value
        return hash
    }

    func hmset(key: String, _ params:[String:String]) throws -> String {
        var ps = [String]()
        ps.append(key)
        for (k, v) in params {
            ps.append(k)
            if v == "" {
                ps.append("\"\"") //empty string
            } else {
                ps.append(v)
            }
        } 
        return try command("HMSET", params:ps).toString()
    }

    func hincrby(set: String, _ key: String, _ value: String) throws -> Int {
        return try command("HINCRBY", params:[set, key, value]).toInt()
    }

    func zcard(set: String) throws -> Int {
        return try command("ZADD", params:[set]).toInt()
    }

    func zadd(set: String, _ key: String, _ value: String) throws -> Int {
        return try command("ZADD", params:[set, key, value]).toInt()
    }

    func zscore(key: String, _ member: String) -> Int? {
        do {
            return try command("ZSCORE", params: [key, member]).toInt()
        } catch {
            return nil
        }
    }

    func zrange(set: String, _ start: String, _ end: String, withScores: Bool = false) throws -> [String] {
        let params: [String] = { () -> [String] in
            if withScores {
                return [set, start, end, "WITHSCORES"]
            }
            return [set, start, end]
        }()
        let result = try command("ZRANGE", params: params).toArray().map({ try $0.toString() })
        return result
    }

    func zrevrange(set: String, _ start: String, _ end: String, withScores: Bool = false) throws -> [String] {
        let params: [String] = { () -> [String] in
            if withScores {
                return [set, start, end, "WITHSCORES"]
            }
            return [set, start, end]
        }()
        let result = try command("ZREVRANGE", params: params).toArray().map({ try $0.toString() })
        return result
    }

}