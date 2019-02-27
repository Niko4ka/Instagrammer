import Foundation

final class RequestService {
    
    //Consts
    static let shared = RequestService()
    private let scheme = "http"
    private let host = "localhost"
    private let port = 8080
    private let usersPath = "/users"
    private let postsPath = "/posts"
    
    // Setting variables
    public var userId: String!
    public var postId: String!
    public var userToken: String?

    public func createRequest(currentCase: APIRequestCases, caseJson: [String: Any]? = nil) -> URLRequest? {
        
        var jsonData: Data?
        var componentsPath: String!
        var requestHttpMethod: String?
        var requestHeaders: [String : String]?
        var requestBody: Data?
        
        if caseJson != nil {
            jsonData = try? JSONSerialization.data(withJSONObject: caseJson as Any, options: .prettyPrinted)
        }
        
        switch currentCase {
        case .signin:
            componentsPath = "/signin"
            requestHttpMethod = "POST"
            requestHeaders = [
                "Content-Type" : "application/json"
            ]
            requestBody = jsonData
            
        case .signout:
            componentsPath = "/signout"
            requestHttpMethod = "POST"
            
            if let token = userToken {
                requestHeaders = [
                    "Content-Type" : "multipart/form-data",
                    "token" : token
                ]}
            
        case .checkToken:
            componentsPath = "/checkToken"
            requestHttpMethod = "GET"
            
            if let json = caseJson {
                let token = json["token"] as! String
                requestHeaders = [
                    "Content-Type" : "multipart/form-data",
                    "token" : token
                    ]}

        case .usersMe:
            componentsPath = usersPath + "/me"
            requestHttpMethod = "GET"
            
            if let token = userToken {
                requestHeaders = [
                    "Content-Type" : "multipart/form-data",
                    "token" : token
                ]}
            
        case .usersId:
            componentsPath = usersPath + "/" + userId
            requestHttpMethod = "GET"
            
            if let token = userToken {
                requestHeaders = [
                    "Content-Type" : "multipart/form-data",
                    "token" : token
                ]}
        
        case .usersFollow:
            componentsPath = usersPath + "/follow"
            requestHttpMethod = "POST"
            requestBody = jsonData

            if let token = userToken {
                requestHeaders = [
                    "Content-Type" : "application/json",
                    "token" : token
                ]}
        
        case .usersUnfollow:
            componentsPath = usersPath + "/unfollow"
            requestHttpMethod = "POST"
            requestBody = jsonData

            if let token = userToken {
                requestHeaders = [
                    "Content-Type" : "application/json",
                    "token" : token
                ]}
        
        case .usersIdFollowers:
            componentsPath = usersPath + "/" + userId + "/followers"
            requestHttpMethod = "GET"
            
            if let token = userToken {
                requestHeaders = [
                    "Content-Type" : "multipart/form-data",
                    "token" : token
                ]}
            
        case .usersIdFollowing:
            componentsPath = usersPath + "/" + userId + "/following"
            requestHttpMethod = "GET"
            
            if let token = userToken {
                requestHeaders = [
                    "Content-Type" : "multipart/form-data",
                    "token" : token
                ]}
        
        case .usersIdPosts:
            componentsPath = usersPath + "/" + userId + "/posts"
            requestHttpMethod = "GET"
            
            if let token = userToken {
                requestHeaders = [
                    "Content-Type" : "multipart/form-data",
                    "token" : token
                ]}
       
        case .postsFeed:
            componentsPath = postsPath + "/feed"
            requestHttpMethod = "GET"
            
            if let token = userToken {
                requestHeaders = [
                    "Content-Type" : "multipart/form-data",
                    "token" : token
                ]}
            
        case .postsId:
            componentsPath = postsPath + "/" + postId
            requestHttpMethod = "GET"
            
            if let token = userToken {
                requestHeaders = [
                    "Content-Type" : "multipart/form-data",
                    "token" : token
                ]}
            
        case .postsLike:
            componentsPath = postsPath + "/like"
            requestHttpMethod = "POST"
            requestBody = jsonData
            
            if let token = userToken {
                requestHeaders = [
                    "Content-Type" : "application/json",
                    "token" : token
                ]}
        
        case .postsUnlike:
            componentsPath = postsPath + "/unlike"
            requestHttpMethod = "POST"
            requestBody = jsonData
            
            if let token = userToken {
                requestHeaders = [
                    "Content-Type" : "application/json",
                    "token" : token
                ]}
            
        case .postsIdLikes:
            componentsPath = postsPath + "/" + postId + "/likes"
            requestHttpMethod = "GET"
            
            if let token = userToken {
                requestHeaders = [
                    "Content-Type" : "multipart/form-data",
                    "token" : token
                ]}
            
        case .postsCreate:
            componentsPath = postsPath + "/create"
            requestHttpMethod = "POST"
            requestBody = jsonData
            
            if let token = userToken {
                requestHeaders = [
                    "Content-Type" : "application/json",
                    "token" : token
                ]}
        }
        
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        components.path = componentsPath
        
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        
        if let httpMethod = requestHttpMethod {
            request.httpMethod = httpMethod
        }
        
        if let headers = requestHeaders {
            request.allHTTPHeaderFields = headers
        }
        
        if let httpBody = requestBody {
            request.httpBody = httpBody
        }

        print("Request - \(request)")
        return request
    }
    
    
}
