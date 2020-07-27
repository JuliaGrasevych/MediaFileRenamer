//
//  FileDropHandler.swift
//  MediaFileRenamer
//
//  Created by Julia on 27.07.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import Foundation
import Combine
import AVFoundation

final class FileFetcher {
    private static let fileManager = FileManager.default
    
    static func fetchFiles(at url: URL) -> AnyPublisher<[FileModel], Never> {
        var isDir: ObjCBool = false
        guard fileManager.fileExists(atPath: url.relativePath, isDirectory: &isDir) else {
            return Just([]).eraseToAnyPublisher()
        }

        guard isDir.boolValue else {
            guard URL.supportedAudioTypes.contains(url.utType()) else { return Just([]).eraseToAnyPublisher() }
            return Just([FileModel(url: url)]).eraseToAnyPublisher()
        }
        do {
            let files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
            return Publishers.MergeMany(files.map { fetchFiles(at: $0) }).eraseToAnyPublisher()
        } catch let exception {
            debugPrint("[FileFetcher] \(exception)")
            return Just([]).eraseToAnyPublisher()
        }
    }
}

extension URL {
    static let supportedAudioTypes = [
        kUTTypeMP3 as String,
        kUTTypeMPEG4Audio as String,
        kUTTypeAppleProtectedMPEG4Audio as String,
        AVFileType.m4a.rawValue
        ] as [String]
    func utType() -> String {
        let pathExtension = self.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            return uti as String
        }
        return kUTTypeData as String
    }
}
