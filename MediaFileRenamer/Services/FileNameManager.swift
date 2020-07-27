//
//  FileNameManager.swift
//  MediaFileRenamer
//
//  Created by Julia on 27.07.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import Foundation
import Combine

final class FileNameManager {
    enum RenamingError: Error {
        case noNewFilename
    }
    
    private static let fileManager = FileManager.default

    static func rename(item: FileModel, proposedFilename: String) throws {
        let initialFilename = item.filename
        if initialFilename == proposedFilename { throw RenamingError.noNewFilename }
        let dirPath = item.url.deletingLastPathComponent()
        let filePath = dirPath.appendingPathComponent(proposedFilename)
        
        try fileManager.moveItem(at: item.url, to: filePath)
        item.url = filePath
    }
}
