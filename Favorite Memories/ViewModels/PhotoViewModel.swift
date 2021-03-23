//
//  PhotosViewModel.swift
//  Favorite Memories
//
//  Created by Epsilon User on 17/3/21.
//

import Foundation
import UIKit


struct PhotoViewModel {
    var id: Int16
    var title: String
    var thumbURL: String
    var imageURL: String
    var imageThumb: UIImage?
    var tag: String = ""
    var tagColor: UIColor = .primaryColor
    
    init(photo: Photos) {
        self.id = photo.id
        self.title = photo.title
        self.thumbURL = photo.thumbnailUrl ?? ""
        self.imageURL = photo.imageUrl
        let imageTag = getPhotoTag(tagID: photo.tag)
        self.tag = imageTag.0
        self.tagColor = imageTag.1
        self.imageThumb = UIImage(named: "Placeholder")
    }
    
    
    /// Function to receive image from local file system or server. The functions checks if file exists and then performs a server task. The function is used in thumbnail and full image.
    /// - Parameters:
    ///   - isThumb: Flag to identify wether the image should be stored as a thumb or full image.
    /// - Returns: Nilable image (nil is returned only in the full image call, to show a prevention alert)
    public func getImage(isThumb: Bool, completion: @escaping (UIImage?) -> ()) {
        if let image = DocumentsHelper.loadImage(image: isThumb ? "thumb_\(id)" : String(describing: id)) {
            completion(image)
            return
        } else {
            if let imageURL = URL(string: isThumb ? thumbURL : imageURL) {
                WebService.shared.fetchImage(url: imageURL) { (error, data) in
                    guard let imageData = data, error == nil else {
                        print(error?.localizedDescription ?? "")
                        if isThumb {
                            completion(UIImage(named: "Placeholder"))
                        } else {
                            completion(nil)
                        }
                        return
                    }
                    let image = UIImage(data: imageData)
                    DocumentsHelper.saveToDocuments(image: image, filename: isThumb ? "thumb_\(id)" : String(describing: id))
                    completion(UIImage(data: imageData))
                    return
                }
            } else {
                completion(UIImage(named: "Placeholder"))
                return
            }
        }
    }
    
    
    /// Set photo tag for photo
    /// - Parameter tagID: The id of the tag, created in the CoreData insert (random 0..2)
    /// - Returns: Tuple of tag name and respective color
    public func getPhotoTag(tagID: Int16) -> (String, UIColor) {
        switch tagID {
        case 0:
            return ("Family Time", .magenta)
        case 1:
            return ("Vacations", .blue)
        case 2:
            return ("Friends", .brown)
        default:
            return ("", .primaryColor)
        }
    }
}
