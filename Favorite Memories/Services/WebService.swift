//
//  WebService.swift
//  Favorite Memories
//
//  Created by Stavros Tsikinas on 11/3/21.
//

import Foundation

class WebService {
    // MARK: - Variables
    // Public Variables
    public static let shared = WebService()
    
    // Private Variables
    private let baseUrl = "http://testapi.pinch.nl:3000/"
    private let serviceTimeout = 60.0
    
    // MARK: - Initializers
    private init() {}
    
    
    // MARK: - Fetchers
    
    public func fetchAlbums(completionHandler: @escaping (WebServiceError?) -> ()) {
        // It's a valid URL, so unwrap is accepted ;)
        let url = URL(string: baseUrl + "albums")!
        // Set timeout to prevent undefined waiting
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: serviceTimeout)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let completionError = error {
                if completionError.localizedDescription.contains("connection") || completionError.localizedDescription.contains("offline") {
                    completionHandler(.connectionRefused)
                } else {
                    completionHandler(.requestError(description: completionError.localizedDescription))
                }
                return
            }
            
            // Make sure that we don't have connection issues, or server failures
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.dataParseError)
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                completionHandler(.responseCodeError(errorCode: httpResponse.statusCode))
                return
            }
            
            if let completionData = data {
                do {
                    if let albumsJSON = try JSONSerialization.jsonObject(with: completionData, options: []) as? [[String: Any]] {
                        DatabaseService.shared.save(albums: albumsJSON) { (saved) in
                            if saved {
                                completionHandler(nil)
                            } else {
                                completionHandler(.dataParseError)
                            }
                            return
                        }
                    } else {
                        completionHandler(.dataParseError)
                        return
                    }
                } catch {
                    print(error)
                    completionHandler(.genericError)
                    return
                }
            }
        }
        task.resume()
    }
    
    /// - Parameter albumID : id of the album to filter our photos
    /// - Parameter page: int to use pagination
    /// - Parameter completionHandler: The respose of the url request returning list of photos and/or possible error message
    public func fetchPhotos(albumID: Int16, page: Int16, completionHandler: @escaping (WebServiceError?, Int16) -> ()) {
        // It's a valid URL, so unwrap is accepted ;)
        let url = URL(string: baseUrl + "photos?albumId=\(albumID)&_page=\(page)")!
        // Set timeout to prevent undefined waiting
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: serviceTimeout)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let completionError = error {
                if completionError.localizedDescription.contains("connection") || completionError.localizedDescription.contains("offline") {
                    completionHandler(.connectionRefused, page)
                } else {
                    completionHandler(.requestError(description: completionError.localizedDescription), page)
                }
                return
            }
            
            // Make sure that we don't have connection issues, or server failures
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.dataParseError, page)
                return
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                completionHandler(.responseCodeError(errorCode: httpResponse.statusCode), page)
                return
            }
            
            if let completionData = data {
                do {
                    if let photosJSON = try JSONSerialization.jsonObject(with: completionData, options: []) as? [[String: Any]] {
                        DatabaseService.shared.save(photos: photosJSON) { (saved) in
                            if saved {
                                DatabaseService.shared.update(albumId: albumID, page + 1)
                                completionHandler(nil, page + 1)
                            } else {
                                completionHandler(.dataParseError, page)
                            }
                        }
                    } else {
                        completionHandler(.dataParseError, page)
                    }
                    return
                } catch {
                    print(error)
                    completionHandler(.genericError, page)
                    return
                }
            } else {
                completionHandler(.genericError, page)
                return
            }
            
        }
        task.resume()
    }
    
    
    /// Get image from server
    /// - Parameters:
    ///   - url: The image url
    /// - Returns: Tuple with error and image Data
    public func fetchImage(url: URL, completionHandler: @escaping (WebServiceError?, Data?) -> ()) {
        let downloadImageTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let imageData = data, error == nil else {
                print(error?.localizedDescription ?? "")
                completionHandler(.requestError(description: error?.localizedDescription ?? ""), nil)
                return
            }
            completionHandler(nil, imageData)
            return
        }
        downloadImageTask.resume()
    }
}
