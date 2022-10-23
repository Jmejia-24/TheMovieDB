//
//  ImageCacheStore.swift
//  TheMovieDB
//
//  Created by Byron Mejia on 10/20/22.
//

import UIKit.UIImage

final class ImageCacheStore {
    static let shared = ImageCacheStore()
    
    private let placeHolder = #imageLiteral(resourceName: "MoviePlaceholder")
    private let cache = NSCache<NSString, UIImage>()
    private let utilityQueue = DispatchQueue.global(qos: .utility)

    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 52428800 // 50MB
    }

    func getCacheImage(for imageURL: String?) async -> UIImage {
        let posterBaseURL = "https://image.tmdb.org/t/p/w500"
        
        guard let imageURL = imageURL else {
            return placeHolder
        }
        
        if let image = cache.object(forKey: NSString(string: imageURL)) {
            
            return image
        
        } else {
            
            do {
                
                let image = try await APIManager.fetchImage(imageURL: posterBaseURL + imageURL)
                cache.setObject(image, forKey: NSString(string: imageURL))
                return image
            
            } catch {
                return placeHolder
            }
        }
    }
}
