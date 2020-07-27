//
//  ItemSection.swift
//  MediaFileRenamer
//
//  Created by Iuliia Grasevych on 07.05.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import Foundation

struct ItemSection<Item: Hashable>: Identifiable, Hashable {
    let id: String
    let items: [Item]
}

typealias ArtistSection = ItemSection<FileViewModel>
