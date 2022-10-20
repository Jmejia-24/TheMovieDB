//
//  APIManager.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/19/22.
//

import Foundation
import Combine

let APIKEY = "ac3f2804a9f15f289b61366bb07cf6b4"

protocol LoginStore {
    func createToken() -> Future<AutResponse, Failure>
    func createLogin(username: String, password: String, token: String) -> Future<AutResponse, Failure>
}

final class APIManager {

    private func request<T: Codable>(for path: String, with queryItems: [URLQueryItem]? = nil, httpMethod: HttpMethod) -> Future<T, Failure> where T : Codable {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = path
        components.queryItems = [
           URLQueryItem(name: "api_key", value: APIKEY),
           URLQueryItem(name: "language", value: Locale.preferredLanguages.first)
        ]
        
        if let params = queryItems {
            params.forEach { query in
                components.queryItems?.append(query)
            }
        }
        
        return Future { promise in
            
            guard let url = components.url else { return promise(.failure(.urlConstructError)) }
            
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod.rawValue
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, case .none = error else { return promise(.failure(.urlConstructError)) }
                
                do {
                    let decoder = JSONDecoder()
                    let searchResponse = try decoder.decode(T.self, from: data)
                    promise(.success(searchResponse))
                    
                } catch {
                    promise(.failure(.APIError(error)))
                }
            }
            
            task.resume()
        }
    }
}

extension APIManager: LoginStore {
    func createToken() -> Future<AutResponse, Failure> {
        request(for: "/3/authentication/token/new", httpMethod: .get)
    }
    
    func createLogin(username: String, password: String, token: String) -> Future<AutResponse, Failure> {
        let path = "/3/authentication/token/validate_with_login"
        let queryItems = [URLQueryItem(name: "username", value: username),
                          URLQueryItem(name: "password", value: password),
                          URLQueryItem(name: "request_token", value: token)]
        return request(for: path, with: queryItems, httpMethod: .post)
    }
}
