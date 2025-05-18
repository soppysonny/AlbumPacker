//
//  FetchOptions.swift
//  AlbumPacker
//
//  Created by lava on 2025/5/10.
//

import Foundation
import Photos
    /*
     PHAssetMediaType
     PHAssetMediaSubtype
     creationDate
     modificationDate NSPredicate(format: "creationDate > %@", startDate as NSDate)
     favorite let predicate = NSPredicate(format: "favorite = YES")
     hidden = NO
     duration duration BETWEEN {%f, %f}
     PHAssetCollection:
     estimatedAssetCount NSPredicate(format: "estimatedAssetCount > 0")
     
     
     */

/**
 let typePredicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
 let favoritePredicate = NSPredicate(format: "favorite = YES")
 let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [typePredicate, favoritePredicate])
 */

class FetchOptions {
    
    var mediaTypes: [PHAssetMediaType] = [.video, .image, .audio, .unknown]

    var displayedMediaType = DisplayedOptions(title: "Media Type".localized(),
                                              options: [
                                                 PHAssetMediaType.video,
                                                 PHAssetMediaType.audio,
                                                 PHAssetMediaType.image,
                                                 PHAssetMediaType.unknown
                                              ], selectedOptions: [
                                                 PHAssetMediaType.video,
                                                 PHAssetMediaType.audio,
                                                 PHAssetMediaType.image,
                                                 PHAssetMediaType.unknown
                                              ])
    
    var creationDate = DisplayedOptions(title: "Creation Date",
                                                    options: [
                                                        DateOption.pastMonth,
                                                        DateOption.pastYear,
                                                        DateOption.custom(begin: nil, end: nil)
                                                    ], selectedOptions: [
                                                        DateOption.pastMonth
                                                    ])
    
    
    var favorite = DisplayedOptions(title: "Show Favorite",
                                    options: [
                                        FavoriteOption.all,
                                        FavoriteOption.onlyFavorite
                                    ], selectedOptions: [
                                        FavoriteOption.all
                                    ])
    
    var hidden = DisplayedOptions(title: "",
                                  options: [
                                    HiddenOption.hidden,
                                    HiddenOption.notHidden,
                                    HiddenOption.noSetting
                                  ],
                                  selectedOptions: [
                                    HiddenOption.noSetting
                                  ])
    
//    var creationDate
    lazy var displayOptions: [DisplayedOptions] = {
       [
        displayedMediaType,
        creationDate,
        favorite
       ]
    }()
    
}
