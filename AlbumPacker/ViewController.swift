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

    private var thumbnailCache: [IndexPath: NSImage] = [:]

    private var infoCache: [IndexPath: [AnyHashable: Any]] = [:]
    
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
//        fetchVideo()
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
        
        let layout = NSCollectionViewFlowLayout()
        layout.itemSize = NSSize(width: 50, height: 50)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        photoListView.collectionViewLayout = layout
        
        view.addSubview(photoListView)
        photoListView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom)
            make.left.equalTo(30)
            make.bottom.right.equalTo(-30)
        }
        photoListView.delegate = self
        photoListView.dataSource = self
        photoListView.register(PhotoCell.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PhotoCell"))
        downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        reloadPhotoList()
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
    
    func checkAuth(completion: @escaping ((PHAuthorizationStatus)->Void)) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            completion(status)
        }
    }

    
    func reloadPhotoList() {
        checkAuth { [weak self] status in
            guard let self else { return }
            guard status == .authorized else { return }
            let fetchOption = PHFetchOptions()
            fetchOption.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
            fetchOption.fetchLimit = 30
            fetchOption.sortDescriptors
            let asset  = PHAsset.fetchAssets(with: .video, options: fetchOption)
            
            self.result = asset
            DispatchQueue.main.async {
                self.photoListView.reloadData()
            }
        }
        
//        asset.enumerateObjects { asset, index, stop in
//
//        }
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
        print("debug.result.count:", result.count)
        return result.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PhotoCell"),
                                                 for: indexPath) as? PhotoCell else {
            fatalError()
        }
        let asset = result.object(at: indexPath.item)
        requestThumbImage(asset: asset, indexPath: indexPath) { [weak self] image, info in
            self?.reloadIndexPath(indexPath, image: image)
        }
        return cell
    }
    
    private func requestThumbImage(asset: PHAsset,
                                   indexPath: IndexPath,
                                   completion: @escaping (NSImage, [AnyHashable: Any])->Void) {
        if let image = thumbnailCache[indexPath],
           let info = infoCache[indexPath] {
            completion(image, info)
          return
        }
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .opportunistic  // 图像质量模式
        requestOptions.isNetworkAccessAllowed = true     // 允许从iCloud加载
        requestOptions.isSynchronous = false
        manager.requestImage(for: asset,
                             targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                             contentMode: .aspectFit,
                             options: requestOptions) { [weak self] image, info in
            print("debug.downloaded:", info ?? [:])
            guard let self = self,
                  let image else {
                return
            }
            self.thumbnailCache[indexPath] = image
            self.infoCache[indexPath] = info
            completion(image, info ?? [:])
        }
    }
    
    private func reloadIndexPath(_ indexPath: IndexPath, image: NSImage) {
        guard let cell = photoListView.item(at: indexPath) as? PhotoCell else {
            return
        }
        cell.configure(image: image)
    }
    
}

//    func fetchVideo() {
//        let minDuration: TimeInterval = 239
//        let maxDuration: TimeInterval = 241
//
//        // 2. 构建谓词
//        let predicate = NSPredicate(
//            format: "mediaType = %d AND duration BETWEEN {%f, %f}",
//            PHAssetMediaType.video.rawValue,
//            minDuration,
//            maxDuration
//        )
//
//        // 3. 配置 FetchOptions
//        let fetchOptions = PHFetchOptions()
//        fetchOptions.predicate = predicate
//
//        // 4. 执行查询
//        let videoAssets = PHAsset.fetchAssets(with: fetchOptions)
//
//        // 5. 遍历结果
//        videoAssets.enumerateObjects { (asset, _, _) in
//            print("视频时长：\(asset.duration) 秒")
//
//            self.exportVideo(asset: asset) { result in
//                switch result {
//                case .success(let success):
//                    print("success:", success)
//                case .failure(let failure):
//                    print("failure:", failure)
//                }
//            }
//        }
//    }

//    func exportVideo(asset: PHAsset, completion: @escaping (Result<URL, Error>) -> Void) {
//        let options = PHVideoRequestOptions()
//        options.isNetworkAccessAllowed = true
//        options.version = .original // 或 .current 处理编辑后的视频[8](@ref)
//        options.deliveryMode = .highQualityFormat
//
//        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, info in
//            print(info)
//            guard let avAsset = avAsset as? AVURLAsset else {
//                completion(.failure(NSError(domain: "ExportError", code: 0, userInfo: nil)))
//                return
//            }
//
//            let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetHighestQuality)
//            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("video_\(UUID().uuidString).mp4")
//
//            exportSession?.outputURL = outputURL
//            exportSession?.outputFileType = .mp4
//
//            exportSession?.exportAsynchronously {
//                switch exportSession?.status {
//                case .completed:
//                    completion(.success(outputURL))
//                case .failed, .cancelled:
//                    completion(.failure(exportSession?.error ?? NSError()))
//                default: break
//                }
//            }
//        }
//    }
