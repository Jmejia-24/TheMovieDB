//
//  APIManager.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/19/22.
//

import UIKit
import Combine

let APIKEY = "ac3f2804a9f15f289b61366bb07cf6b4"

enum MovieType: String, CaseIterable {
    case popular = "popular"
    case upcoming = "upcoming"
    case nowPlaying = "now_playing"
    case topRated = "top_rated"
}

protocol LoginStore {
    func createToken() -> Future<TokenResponse, APIError>
    func login(username: String, password: String, token: String) -> Future<TokenResponse, APIError>
    func createSession(requestToken: String) -> Future<CreateSessionResponse, APIError>
    func getAccountDetails(sessionId: String) -> Future<Profile, APIError>
}

protocol MovieListStore {
    func getMoviesList(for moviesType: String, with offset: Int) -> Future<PaginatedResponse<Movie>, APIError>
}

protocol MovieDetailStore {
    func getMovieDetail(for movieId: Int) -> Future<Movie, APIError>
}

protocol ProfileStore {
    func getMovieFavorite(accountId: Int, sessionId: String, with offset: Int) -> Future<PaginatedResponse<Movie>, APIError>
}

final class APIManager {
    
    private func request<T>(for path: String, with queryItems: [URLQueryItem]? = nil, httpMethod: HttpMethod = .get) -> Future<T, APIError> where T : Codable {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = "/3/\(path)"
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
            
            guard let url = components.url else { return promise(.failure(genericError)) }
            
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod.rawValue
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, case .none = error else { return promise(.failure(genericError)) }
                
                do {
                    let decoder = JSONDecoder()
                    let searchResponse = try decoder.decode(T.self, from: data)
                    promise(.success(searchResponse))
                    
                } catch {
                    guard let response = response as? HTTPURLResponse else { return }
                    promise(.failure(.handleError(dataResponse: response, data: data)))
                }
            }
            
            task.resume()
        }
    }
    
    static func fetchImage(imageURL: String) async throws -> UIImage {
        guard let url = URL(string: imageURL) else { throw genericError }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard
                let statusCode = (response as? HTTPURLResponse)?.statusCode,
                let image = UIImage(data: data), 200...299 ~= statusCode else { throw genericError }
            return image
            
        } catch {
            throw error
        }
    }
}

extension APIManager: LoginStore {
    
    func createToken() -> Future<TokenResponse, APIError> {
        request(for: "authentication/token/new")
    }
    
    func login(username: String, password: String, token: String) -> Future<TokenResponse, APIError> {
        let path = "authentication/token/validate_with_login"
        let queryItems = [URLQueryItem(name: "username", value: username),
                          URLQueryItem(name: "password", value: password),
                          URLQueryItem(name: "request_token", value: token)]
        return request(for: path, with: queryItems, httpMethod: .post)
    }
    
    func createSession(requestToken: String) -> Future<CreateSessionResponse, APIError> {
        let queryItems = [URLQueryItem(name: "request_token", value: requestToken)]
        let path = "authentication/session/new"
        return request(for: path, with: queryItems, httpMethod: .post)
    }
    
    func getAccountDetails(sessionId: String) -> Future<Profile, APIError> {
        let queryItems = [URLQueryItem(name: "session_id", value: sessionId)]
        return request(for: "account", with: queryItems)
    }
}

extension APIManager: MovieListStore {
    func getMoviesList(for moviesType: String, with offset: Int) -> Future<PaginatedResponse<Movie>, APIError> {
        let path = "movie/\(moviesType)"
        let queryItems = [URLQueryItem(name: "page", value: "\(offset)")]
        return request(for: path, with: queryItems)
    }
}

extension APIManager: MovieDetailStore {
    func getMovieDetail(for movieId: Int) -> Future<Movie, APIError> {
        let path = "movie/\(movieId)"
        return request(for: path)
    }
}

extension APIManager: ProfileStore {
    func getMovieFavorite(accountId: Int, sessionId: String, with offset: Int) -> Future<PaginatedResponse<Movie>, APIError> {
        let path = "account/\(accountId)/favorite/movies"
        let queryItems = [URLQueryItem(name: "session_id", value: sessionId),
                          URLQueryItem(name: "sort_by", value: "created_at.asc"),
                          URLQueryItem(name: "page", value: "\(offset)")]
        
        return request(for: path, with: queryItems)
    }
}
