//
//  String+Extension.swift
//  AlbumPacker
//
//  Created by lava on 2025/4/29.
//

import Foundation

extension String {
    func localized() -> String {
        NSLocalizedString(self, comment: "")
    }
}
