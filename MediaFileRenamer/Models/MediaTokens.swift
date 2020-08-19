//
//  MediaTokens.swift
//  MediaFileRenamer
//
//  Created by Julia on 07.08.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import Foundation

enum MediaToken: String {
    case artist = "artist"
    case title = "title"
    case album = "album"
    case track = "track"
    case year = "year"
    
    var title: String {
        self.rawValue
    }
}

extension MediaToken: CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }
}
