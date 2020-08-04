//
//  FileModel.swift
//  MediaFileRenamer
//
//  Created by Iuliia Grasevych on 07.05.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import Foundation
import AVFoundation

typealias FileID = URL

struct FileModel: Identifiable, Hashable {
    static func == (lhs: FileModel, rhs: FileModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: FileID { url }
    
    private(set) var filename: String
    var url: URL {
        didSet {
            filename = url.lastPathComponent
        }
    }
    let `extension`: String
    let mediaInfo: MediaInfo
    
    init(url: URL) {
        self.url = url
        self.filename = url.lastPathComponent
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

extension FileID {
    var identityString: String { self.absoluteString }
}
