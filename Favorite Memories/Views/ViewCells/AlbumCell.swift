//
//  AlbumCell.swift
//  Favorite Memories
//
//  Created by Epsilon User on 11/3/21.
//

import UIKit

class AlbumCell: UICollectionViewCell {

    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var albumTitle: UILabel!
    
    var albumVM: AlbumViewModel! {
        didSet {
            albumTitle.text = albumVM.title
            albumImage.image = UIImage(named: "Album")?.withTintColor(albumVM.albumColor)
        }
    }
}
