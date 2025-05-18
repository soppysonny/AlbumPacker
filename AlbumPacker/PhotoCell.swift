//
//  PhotoCell.swift
//  AlbumPacker
//
//  Created by lava on 2025/4/29.
//

import AppKit
import SnapKit


class PhotoCell: NSCollectionViewItem {
    
    var thumbnailImageView: NSImageView!
    var label: NSTextField!
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 50, height: 50))
        view.layer?.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 缩略图视图
        thumbnailImageView = NSImageView(frame: NSRect(x: 10, y: 20, width: 100, height: 100))
        thumbnailImageView.imageScaling = .scaleProportionallyDown
        // 标签（如创建时间）
        view.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.height.equalTo(50)
        }
    }
    
    func configure(image: NSImage?) {
        thumbnailImageView.image = image
    }
    
}
