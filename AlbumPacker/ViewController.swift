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
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
     
    private var configItems: [SettingItem] = [
        .init(title: "下载隐藏项", options: ["是", "否"], storageKey: "downloadhiddenitem"),
        .init(title: "下载照片类型", options: ["全部", "共享相册", "iTunesSynced"], storageKey: "albumtype"),
        .init(title: "是否下载连拍照片", options: ["是", "否"], storageKey: "downloadBurst")
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
            make.edges.equalTo(NSEdgeInsets(top: 30, left: 30, bottom: -30, right: -30))
        }
        downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
    }
    private func createSettingRow(item: SettingItem) -> NSView {
        let row = NSStackView()
        row.distribution = .fillEqually
        
        // 标题标签
        let label = NSTextField(labelWithString: item.title)
        label.font = NSFont.systemFont(ofSize: 14)
        
        // 下拉菜单
        let popup = NSPopUpButton()
        popup.addItems(withTitles: item.options)
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
