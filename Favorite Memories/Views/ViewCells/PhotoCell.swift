//
//  PhotoCell.swift
//  Favorite Memories
//
//  Created by Epsilon User on 17/3/21.
//

import UIKit

class PhotoCell: UITableViewCell {
    
    @IBOutlet weak var itemView: UIView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var photoTitle: UILabel!
    @IBOutlet weak var photoTag: UIButton!
    
    
    var photoVM: PhotoViewModel! {
        didSet {
            photoTitle.text = photoVM.title
            photoImage.image = photoVM.imageThumb!
            photoTag.setTitle(photoVM.tag, for: .normal)
            photoTag.backgroundColor = photoVM.tagColor
        }
    }
}
