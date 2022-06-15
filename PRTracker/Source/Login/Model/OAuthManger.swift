//
//  LoginModel.swift
//  PRTracker
//
//  Created by Bumgeun Song on 2022/06/13.
//

import Foundation
import UIKit


struct OAuthManger {
    
    static let shared = OAuthManger()
    
    static let clientId = "3d45d9cbd8c6e918841f"
    static let requiredScope = "repo,user"
    static let authorizeBaseURL = "https://github.com/login/oauth/authorize"
    static let accessTokenURL = "https://github.com/login/oauth/access_token"
    
    func requestAuthorization() {
        guard var components = URLComponents(string: OAuthManger.authorizeBaseURL) else { return }
        components.queryItems = [
            URLQueryItem(name: "client_id", value: OAuthManger.clientId),
            URLQueryItem(name: "scope", value: OAuthManger.requiredScope)
        ]
        guard let url = components.url else { return }
        print(url)
        UIApplication.shared.open(url)
    }
    
    func requestToken(with code: String) {
        guard var components = URLComponents(string: OAuthManger.accessTokenURL) else { return }
        components.queryItems = [
            URLQueryItem(name: "client_id", value: OAuthManger.clientId),
            URLQueryItem(name: "client_secret", value: "52a894bc76ecd46fb0912638a5d5b672bce7fb81"),
            URLQueryItem(name: "code", value: code)
        ]
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                Log.error(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                Log.error("Missing data")
                return
            }
            
            guard let tokenReponse = try? JSONDecoder().decode(TokenResponse.self, from: data) else {
                Log.error("Decoding failed")
                return
            }
            
            let keyChainManager = KeyChainManager()
            let accessTokenData = Data(tokenReponse.accessToken.utf8)
            keyChainManager.save(accessTokenData, service: "access-token", account: "github")
            
        }.resume()
    }
}

