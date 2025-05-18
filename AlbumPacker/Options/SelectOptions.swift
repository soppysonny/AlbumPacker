//
//  SelectOptions.swift
//  AlbumPacker
//
//  Created by lava on 2025/5/11.
//

import Foundation
import Photos

extension PHAssetMediaType: Option {
    var title: String {
        switch self {
        case .unknown:
            return "unknown".localized()
        case .image:
            return "image".localized()
        case .video:
            return "video".localized()
        case .audio:
            return "audio".localized()
        @unknown default:
            return ""
        }
    }
    
    static var allowMultipleSelection: Bool { true }
    
    
}

enum DateOption: Option {
    case pastMonth
    case pastYear
    case custom(begin: Date?, end: Date?)
    var title: String {
        switch self {
        case .pastYear: return "Past year".localized()
        case .pastMonth: return "Past month".localized()
        case .custom: return "Specified period".localized()
        }
    }
    
    static var allowMultipleSelection: Bool { false }
    
}

enum FavoriteOption: Option {
    case all
    case onlyFavorite
    
    var title: String {
        switch self {
        case .all:
            return "All".localized()
        case .onlyFavorite:
            return "Only Favorited".localized()
        }
    }
    
    static var allowMultipleSelection: Bool { false }
    
}

enum HiddenOption: Option {
    case notHidden
    case hidden
    case noSetting
    
    var title: String {
        switch self {
        case .notHidden:
            return "Not hidden".localized()
        case .hidden:
            return "Only hidden".localized()
        case .noSetting:
            return "No Setting".localized()
        }
    }
    
    static var allowMultipleSelection: Bool { false }
}

enum VideoDurationOption: Option {
    case under60s
    case from60sTo120s
    case custom(durationFrom: Int, durationTo: Int)
    
    var title: String {
        switch self {
        case .under60s:
            return "Less than 60 seconds".localized()
        case .from60sTo120s:
            return "From 60 to 120 seconds".localized()
        case .custom:
            return "Set duration"
        }
    }
    
    static var allowMultipleSelection: Bool { false }
    
}
