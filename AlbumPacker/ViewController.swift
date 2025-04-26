//
//  ViewController.swift
//  AlbumPacker
//
//  Created by lava on 2025/4/26.
//

import Cocoa
import Photos
class ViewController: NSViewController {
    // MARK: - 使用示例
    let downloader = iCloudDownloader()
    let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!

    @IBOutlet weak var downloadBtn: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    @IBAction func download(_ sender: Any) {
        startDownload()
    }
    
    func startDownload() {
        downloader.downloadAlliCloudPhotos(to: downloadsDirectory) { [weak self] success, error in
            guard let self else { return }
            if success {
                print("所有iCloud照片已下载到: \(self.downloadsDirectory.path)")
            } else if let error = error {
                print("下载失败: \(error.localizedDescription)")
            }
        }
    }

}

class iCloudDownloader: NSObject {
    private let downloadQueue = OperationQueue()
    private var completionHandler: ((Bool, Error?) -> Void)?
    
    override init() {
        super.init()
        downloadQueue.maxConcurrentOperationCount = 3
        downloadQueue.qualityOfService = .userInitiated
    }
    
    // MARK: - 主下载方法
    func downloadAlliCloudPhotos(to directory: URL, completion: @escaping (Bool, Error?) -> Void) {
        self.completionHandler = completion
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        print(status.rawValue)
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            guard status == .authorized else {
                self?.completionHandler?(false, NSError(domain: "PermissionDenied", code: 403))
                return
            }
            
            // 获取iCloud资源
            let fetchOptions = PHFetchOptions()
            fetchOptions.includeAssetSourceTypes = [.typeUserLibrary]
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            fetchOptions.fetchLimit = 30
            let assets = PHAsset.fetchAssets(with: fetchOptions)
            self?.processAssets(assets: assets, outputDirectory: directory)
        }
    }
    
    lazy var options: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.version = .original
        return options
    }()
    
    // MARK: - 资源处理
    private func processAssets(assets: PHFetchResult<PHAsset>, outputDirectory: URL) {
        let totalCount = assets.count
        var processedCount = 0
        
        assets.enumerateObjects { [weak self] (asset, index, stop) in
            let operation = BlockOperation { [weak self] in
                guard let self else { return }
                // 检查本地可用性[3](@ref)
                let resources = PHAssetResource.assetResources(for: asset)
//                let isLocallyAvailable = resources.contains {
//                    $0.type == .photo && ($0.value(forKey: "locallyAvailable") as? Bool ?? false)
//                }
//                
//                guard !isLocallyAvailable else { return }
                
                // 创建下载请求[1,5](@ref)
              
                
                PHImageManager.default().requestImageDataAndOrientation(
                    for: asset,
                    options: self.options
                ) { (data, _, _, info) in
                    guard let imageData = data else { return }
                    
                    // 生成唯一文件名[6](@ref)
                    let fileName = "\(asset.originalFilename ?? UUID().uuidString).jpg"
                    let fileURL = outputDirectory.appendingPathComponent(fileName)
                    
                    do {
                        try imageData.write(to: fileURL)
                        processedCount += 1
                        print("Downloaded \(processedCount)/\(totalCount): \(fileURL.path)")
                    } catch {
                        print("Write failed: \(error.localizedDescription)")
                    }
                }
            }
            self?.downloadQueue.addOperation(operation)
        }
        
        // 完成回调
        downloadQueue.addBarrierBlock { [weak self] in
            DispatchQueue.main.async {
                self?.completionHandler?(true, nil)
            }
        }
    }
}

extension PHAsset {
    var originalFilename: String? {
        let resources = PHAssetResource.assetResources(for: self)
        guard let resource = resources.first(where: {
            $0.type == .photo || $0.type == .fullSizePhoto
        }) else { return nil }
        return resource.originalFilename
    }
}
