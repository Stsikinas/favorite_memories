//
//  DocumentsHelper.swift
//  Favorite Memories
//
//  Created by Epsilon User on 21/3/21.
//

import Foundation
import UIKit

class DocumentsHelper {
    
    
    /// Save image to documents directory of application
    /// - Parameters:
    ///   - image: The image to save
    ///   - filename: The file that the image will be saved
    static func saveToDocuments(image: UIImage?, filename: String) {
        let dir = getDocumentsDir()
        if let imageData = image?.pngData() {
            let imageName = dir.appendingPathComponent("\(filename).png")
            if !fileExists(stringPath: imageName.path) {
                do {
                    try imageData.write(to: imageName)
                } catch {
                    print("Unable to save image ID: \(filename). Reason: \(error.localizedDescription)")
                }
            }
        } else {
            print("Could not store image ID: \(filename)")
        }
    }
    
    
    /// This function produces a UIImage to show
    /// - Parameter image: The image name (ID)
    /// - Returns: Nullable image to present if fetched
    static func loadImage(image: String) -> UIImage? {
        let dir = getDocumentsDir()
        let imageName = dir.appendingPathComponent("\(image).png")
        if fileExists(stringPath: imageName.path) {
            do {
                let imageData = try Data(contentsOf: imageName)
                return UIImage(data: imageData)
            } catch {
                print("Unable to load image ID: \(image). Reason: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    
    /// Returns the URL representation of the documents directory of the app
    /// - Returns: The URL of directory
    static func getDocumentsDir() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    
    /// Check if file exists
    /// - Parameter stringPath: The string representation of the filepath
    /// - Returns: A boolean to check if file exists in file system of the app
    static func fileExists(stringPath: String) -> Bool {
        return FileManager.default.fileExists(atPath: stringPath)
    }
    
}
