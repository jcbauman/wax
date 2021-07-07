//
//  SpotifyAuthManager.swift
//  Wax
//
//  Created by Jack Bauman on 7/6/21.
//

import Foundation

final class SpotifyAuthManager{
    static let shared = SpotifyAuthManager()
    
    private init() {}
    
    struct Constants {
        static let clientId = "0b005acd5ac242d7bbbb5ab5fd444a65"
        static let clientS = "8f2a23bce57948f89166f3a9e4b03a40"
        static let tokenAPIUrl = "https://accounts.spotify.com/api/token"
        static let redirectURI = "https://www.spotify.com"
    }
    
    public var signInUrl: URL? {
        let scopes = "user-read-private"
        let redirectURI = Constants.redirectURI
        let base = "https://accounts.spotify.com/authorize?response_type=code"
        let string = "\(base)&client_id=\(Constants.clientId)&scope=\(scopes)&redirect_uri=\(redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.string(forKey: "expiration_date") as? Date
    }
     
    private var shouldRefreshToken: Bool? {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMin: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMin) >= expirationDate
    }
    
    public func getTokenFromCode(code:String, completionHandler: @escaping ((Bool) -> Void )){
        guard let url = URL(string: Constants.tokenAPIUrl) else {
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
        URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded ", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = Constants.clientId+":"+Constants.clientS
        let data = basicToken.data(using: .utf8)
        let base64String = data?.base64EncodedString() ?? ""
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request){[weak self] data, _, error in
            guard let data = data, error == nil else {
                completionHandler(false)
                return
            }
            
            do{
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: result)
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print("SUCCESS, \(json)")
                completionHandler(true)
                
            } catch{
                print(error.localizedDescription)
                completionHandler(false)
            }
        }
        
    }
    
    public func cacheToken(result:AuthResponse){
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        UserDefaults.standard.setValue(result.refresh_token, forKey: "refresh_token")
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expiration_date")
        
        
    }
    
    public func refreshAccessToken(){
        
    }
}
