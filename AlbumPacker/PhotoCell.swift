//
//  PhotoCell.swift
//  AlbumPacker
//
//  Created by lava on 2025/4/29.
//

import AppKit

class PhotoCell: NSCollectionViewItem {
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView?.image = nil
    }

    func setImage(_ image: NSImage?) {
        self.imageView?.image = image
    }
    
    
}
