//
//  SettingItem.swift
//  AlbumPacker
//
//  Created by lava on 2025/4/28.
//

import Foundation
enum SettingType {
    case downloadHidden
    case targetType
    case downloadBurst
    
    var storageKey: String {
        switch self {
        case .downloadHidden:
            return "downloadHidden"
        case .targetType:
            return "targetType"
        case .downloadBurst:
            return "downloadBurst"
        }
    }
    
    var title: String {
        switch self {
        case .downloadHidden:
            return "Download hidden photos".localized()
        case .targetType:
            return "Download photo Type".localized()
        case .downloadBurst:
            return "Download bust photos".localized()
        }
    }
    
    var options: [Option] {
        switch self {
        case .downloadHidden, .downloadBurst:
            return TrueFalseOption.allCases
        case .targetType:
            return DownloadTargetType.allCases
        }
    }
    
}

protocol Option {
    static var allowMultipleSelection: Bool { get }
    var title: String { get }
}

enum DownloadTargetType: CaseIterable, Option {
    case all
    case sharedAlbum
    case iTunesSynced
    
    static var allowMultipleSelection: Bool { false }
    
    var title: String {
        switch self {
        case .all:
            return "All".localized()
        case .sharedAlbum:
            return "Shared album".localized()
        case .iTunesSynced:
            return "iTunes synced".localized()
        }
    }
}

enum TrueFalseOption: Option, CaseIterable {
    case yes
    case no
    
    static var allowMultipleSelection: Bool { false }
    
    var title: String {
        switch self {
        case .yes:
            return "yes".localized()
        case .no:
            return "no".localized()
        }
    }
}
