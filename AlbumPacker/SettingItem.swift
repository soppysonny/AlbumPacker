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
            
        }
    }
    
}

protocol Option {
    
}

enum DownloadTargetType {
    
}

enum TrueFalseOption: Option, CaseIterable {
    case yes
    case no
    
    var title: String {
        switch self {
        case .yes:
            return "yes".localized()
        case .no:
            return "no".localized()
        }
    }
}

struct SettingItem {
    let title: String
    let options: [String]
    let storageKey: String
}
