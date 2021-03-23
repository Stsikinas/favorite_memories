//
//  AlbumViewModel.swift
//  Favorite Memories
//
//  Created by Epsilon User on 16/3/21.
//

import Foundation
import UIKit


struct AlbumViewModel {
    var id: Int16
    var title: String
    var albumColor: UIColor
    var page: Int16
    
    init(album: Albums) {
        id = album.id
        title = album.title
        albumColor = UIColor.primaryColor
        page = album.pageLoaded
    }
}
