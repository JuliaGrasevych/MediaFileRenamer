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
    enum Filename {
        case initial(String)
        case renaming(initial: String, proposed: String)
    }
    
    static func == (lhs: FileModel, rhs: FileModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: URL { url }
    
    let filename: Filename
    let url: URL
    let `extension`: String
    let mediaInfo: MediaInfo
    
    init(url: URL) {
        self.url = url
        self.filename = .initial(url.lastPathComponent)
        self.extension = url.pathExtension
        self.mediaInfo = MediaInfo(fileUrl: self.url)
    }
}

struct MediaInfo: Equatable, Hashable {
    let title: String?
    let artist: String?
    let album: String?
    let track: String?
    let year: String?
    let cover: Data?
}

extension MediaInfo {
    init(fileUrl: URL) {
        let fileAsset = AVAsset(url: fileUrl)
        let metadata = fileAsset.metadata
        
        title = AVMetadataItem.metadataItem(from: metadata, mediaInfo: .title)
        artist = AVMetadataItem.metadataItem(from: metadata, mediaInfo: .artist)
        album = AVMetadataItem.metadataItem(from: metadata, mediaInfo: .album)
        track = AVMetadataItem.metadataItem(from: metadata, mediaInfo: .track)
        year = AVMetadataItem.metadataItem(from: metadata, mediaInfo: .year)
        
        cover = AVMetadataItem.metadataItem(from: metadata, mediaInfo: .cover)
    }
}

extension AVMetadataItem {
    typealias MetadataSource = (key: AVMetadataKey, space: AVMetadataKeySpace)
    enum MediaInfo {
        case title
        case artist
        case album
        case track
        case year
        case cover
        
        var metadataSources: [MetadataSource] {
            switch self {
            case .title:
                return [(.commonKeyTitle, .common), (.iTunesMetadataKeyDescription, .iTunes), (.id3MetadataKeyTitleDescription, .id3)]
            case .artist:
                return [(.commonKeyArtist, .common), (.iTunesMetadataKeyArtist, .iTunes), (.id3MetadataKeyOriginalArtist, .id3)]
            case .album:
                return [(.commonKeyAlbumName, .common), (.iTunesMetadataKeyAlbum, .iTunes), (.id3MetadataKeyAlbumTitle, .id3)]
            case .track:
                return [(.iTunesMetadataKeyTrackNumber, .iTunes), (.id3MetadataKeyTrackNumber, .id3)]
            case .year:
                return [(.commonKeyCreationDate, .common), (.iTunesMetadataKeyReleaseDate, .iTunes), (.id3MetadataKeyYear, .id3)]
            case .cover:
                return [(.commonKeyArtwork, .common), (.iTunesMetadataKeyCoverArt, .iTunes), (.id3MetadataKeyAttachedPicture, .id3)]
            }
        }
    }
    
    static func metadataItem<T>(from metadata: [AVMetadataItem], mediaInfo: MediaInfo) -> T? {
        for metadataSource in mediaInfo.metadataSources {
            if let item = (AVMetadataItem.metadataItems(from: metadata, withKey: metadataSource.key, keySpace: metadataSource.space).first?.value) as? T {
                return item
            }
        }
        return nil
    }
}
