//
//  FileModel.swift
//  MediaFileRenamer
//
//  Created by Iuliia Grasevych on 07.05.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import Foundation
import AVFoundation

class FileModel: Identifiable, Hashable, ObservableObject {
    static func == (lhs: FileModel, rhs: FileModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: URL { url }
    
    let filename: String
    let url: URL
    let `extension`: String
    let mp3Info: Mp3Info
    
    init(url: URL) {
        self.url = url
        self.filename = url.lastPathComponent
        self.extension = url.pathExtension
        self.mp3Info = Mp3Info(fileUrl: self.url)
    }
}

struct Mp3Info: Equatable, Hashable {
    let title: String?
    let artist: String?
    let album: String?
    let track: Int?
    let year: Date?
    let cover: String?
}

extension Mp3Info {
    init(fileUrl: URL) {
        let fileAsset = AVAsset(url: fileUrl)
        let metadata = fileAsset.metadata(forFormat: .iTunesMetadata)
        title = (AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataKey.iTunesMetadataKeySongName, keySpace: nil).first?.value as? String)
        artist = (AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataKey.iTunesMetadataKeyArtist, keySpace: nil).first?.value as? String)
        album = (AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataKey.iTunesMetadataKeyAlbum, keySpace: nil).first?.value as? String)
        track = (AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataKey.iTunesMetadataKeyTrackNumber, keySpace: nil).first?.value as? Int)
        year = (AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataKey.iTunesMetadataKeyReleaseDate, keySpace: nil).first?.value as? Date)
        cover = (AVMetadataItem.metadataItems(from: metadata, withKey: AVMetadataKey.iTunesMetadataKeyCoverArt, keySpace: nil).first?.value as? String)
    }
}
