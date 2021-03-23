//
//  EmptyListView.swift
//  Favorite Memories
//
//  Created by Epsilon User on 22/3/21.
//

import UIKit

class EmptyListView: UIView {
    
    @IBOutlet weak var emptyText: UILabel!
    public var viewType: ViewType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func setuplabel() {
        switch viewType {
            case .AlbumView:
                emptyText.text = "The album list seems to be empty"
                break
            case .PhotosView:
                emptyText.text = "The photo list seems to be empty"
                break
            case .none:
                break
        }
    }

}
