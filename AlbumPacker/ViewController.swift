//
//  ViewController.swift
//  AlbumPacker
//
//  Created by lava on 2025/4/26.
//

import Cocoa
import Photos
import SnapKit
class ViewController: NSViewController {
    let downloader = iCloudDownloader()
    var downloadsDirectory: URL?

    private var downloadBtn = NSButton()
    
    private let photoListView = NSCollectionView()
    
    private var result: PHFetchResult<PHAsset> = .init()
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
     
    private var configItems: [SettingType] = [
        .targetType,
        .downloadHidden,
        .downloadBurst
    ]
 
    override func loadView() {
        super.loadView()
        view = NSView(frame: CGRect(x: 0, y: 0, width: 1200, height: 800))
        view.wantsLayer = true
//        view.layer?.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .leading
        configItems.forEach { item in
            let row = createSettingRow(item: item)
            stackView.addArrangedSubview(row)
        }
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.top.equalTo(30)
            make.right.equalTo(-30)
        }
        
        view.addSubview(photoListView)
        photoListView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom)
            make.left.equalTo(30)
            make.bottom.right.equalTo(-30)
        }
        photoListView.delegate = self
        photoListView.dataSource = self
        photoListView.register(PhotoCell.self, forItemWithIdentifier: "PhotoCell")
        downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
    }
    
    
    private func createSettingRow(item: SettingType) -> NSView {
        let row = NSStackView()
        row.distribution = .gravityAreas
        
        // 标题标签
        let label = NSTextField(labelWithString: item.title)
        label.font = NSFont.systemFont(ofSize: 14)
        
        // 下拉菜单
        let popup = NSPopUpButton()
        popup.addItems(withTitles: item.options.map { $0.title })
        popup.selectItem(at: UserDefaults.standard.integer(forKey: item.storageKey))
        popup.target = self
        popup.action = #selector(popupValueChanged(_:))
        popup.identifier = NSUserInterfaceItemIdentifier(item.storageKey)
        
        row.addArrangedSubview(label)
        row.addArrangedSubview(popup)
        return row
    }
    
    @objc private func popupValueChanged(_ sender: NSPopUpButton) {
        guard let key = sender.identifier?.rawValue else { return }
        UserDefaults.standard.set(sender.indexOfSelectedItem, forKey: key)
    }
 
    private let cachingManager = PHCachingImageManager()
    
    func checkAuth(completion: ((PHAuthorizationStatus)->Void)) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            completion(status)
        }
    }
    
    func reloadPhotoList() {
        checkAuth { status in
            guard status == .authorized else { return }
            
        }
        var fetchOption = PHFetchOptions()
        fetchOption.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
        fetchOption.fetchLimit = 1000
        let asset  = PHAsset.fetchAssets(with: fetchOption)
        asset.enumerateObjects { asset, index, stop in
        
        }
//        cachingManager.startCachingImages(for: self.result,
//                                          targetSize: CGSize(width: 100, height: 100),
//                                          contentMode: .aspectFill,
//                                          options: nil)
    }
    
    func startDownload() {
        guard let downloadsDirectory else { return }
        downloader.downloadAlliCloudPhotos(to: downloadsDirectory) { [weak self] success, error in
            guard let self else { return }
            if success {
                print("所有iCloud照片已下载到: \(downloadsDirectory.path)")
            } else if let error = error {
                print("下载失败: \(error.localizedDescription)")
            }
        }
    }

}

extension ViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        result.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PhotoCell"),
                                                 for: indexPath) as? PhotoCell else {
            fatalError()
        }
        let asset = result.object(at: indexPath.item)
        
        return cell
    }
    
    
}
