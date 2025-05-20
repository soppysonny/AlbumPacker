//
//  DownloadManager.swift
//  AlbumPacker
//
//  Created by lava on 2025/4/28.
//

import Foundation
import Photos

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
            fetchOptions.predicate = NSPredicate(format: "mediaType = %d OR mediaType = %d",  PHAssetMediaType.video.rawValue, PHAssetMediaType.image.rawValue)
            fetchOptions.fetchLimit = 100
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
                
                // 创建下载请求[1,5](@ref)
              
                switch asset.mediaType {
                case .image:
                    PHImageManager.default().requestImageDataAndOrientation(
                        for: asset,
                        options: self.options
                    ) { (data, _, _, info) in
                        guard let imageData = data else { return }
                        
                        // 生成唯一文件名[6](@ref)
                        let fileName = "\(asset.originalFilename ?? UUID().uuidString)"
                        let fileURL = outputDirectory.appendingPathComponent(fileName)
                        
                        do {
                            try imageData.write(to: fileURL)
                            processedCount += 1
                            print("Downloaded \(processedCount)/\(totalCount): \(fileURL.path)")
                        } catch {
                            print("Write failed: \(error.localizedDescription)")
                        }
                    }
                case .video:
                    let options = PHVideoRequestOptions()
                    options.version = .current
                    options.isNetworkAccessAllowed = true
                    options.deliveryMode = .highQualityFormat
                    options.progressHandler = { progress, _, _, _ in
                        print("video.prog:", progress)
                    }
                    PHImageManager.default().requestAVAsset(forVideo: asset, options: options) {
                        (avAsset, _, info) in
                        guard let urlAsset = avAsset as? AVURLAsset else {
                            print("not avasset")
                            return
                        }
                        let filename = asset.value(forKey: "filename") as? String ?? "video_\(Date().timeIntervalSince1970)"
                        print(asset.value(forKey: "filename"), asset.value(forKey: "creationDate"))
                        let fileUrl = outputDirectory.appendingPathComponent(filename)
                        do {
                            try FileManager.default.copyItem(at: urlAsset.url, to: fileUrl)
                        } catch let error {
                            print("video.error:", error.localizedDescription)
                        }
                    }
                default: break
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
