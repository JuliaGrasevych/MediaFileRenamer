//
//  ListViewModel.swift
//  MediaFileRenamer
//
//  Created by Iuliia Grasevych on 07.05.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import Foundation
import Combine
import AVFoundation

class ListViewModel: ObservableObject {
    static let dropFileType = kUTTypeFileURL as String
    static let unknownArtistSection = "Unknown artist"
    
    @Published private(set) var objects: Set<FileModel> = []
    private var dropCancellable: AnyCancellable?
    private var addCancellable: AnyCancellable?
    
    var sections: [ArtistSection] {
        return Dictionary(grouping: objects, by: \.mediaInfo.artist)
            .map { ArtistSection(id: $0.key ?? Self.unknownArtistSection, items: $0.value) }
    }
    
    func handleDrop(itemsProviders: [NSItemProvider]) -> Bool {
        if itemsProviders.isEmpty { return false }
        dropCancellable = FileDropHandler.handleDrop(itemsProviders: itemsProviders, fileType: Self.dropFileType)
            .flatMap { urls -> AnyPublisher<[FileModel], Never> in
                self.fetchFiles(urls: urls)
            }
            .sink { files in
                if files.isEmpty { return }
                self.objects.formUnion(files)
        }
        return true
    }
    
    func handleAdd(urls: [URL]) {
        addCancellable = fetchFiles(urls: urls)
            .sink(receiveValue: { files in
                if files.isEmpty { return }
                self.objects.formUnion(files)
            })
    }
    
    func preview(items: [FileModel]) {
        
    }
    
    private func fetchFiles(urls: [URL]) -> AnyPublisher<[FileModel], Never> {
        return Publishers.MergeMany(urls.map { FileFetcher.fetchFiles(at: $0) }).eraseToAnyPublisher()
    }
}

final class FileDropHandler {
    static func handleDrop(itemsProviders: [NSItemProvider], fileType: String) -> AnyPublisher<[URL], Never> {
        if itemsProviders.isEmpty { return Just([]).eraseToAnyPublisher() }
        
        let subject = PassthroughSubject<[URL], Never>()
        itemsProviders.forEach { provider in
            
            provider.loadItem(forTypeIdentifier: fileType, options: nil) { (data, error) in
                if let error = error {
                    print(error)
                    subject.send([])
                    return
                }
                guard let data = data as? Data else { return }
                print(data)
                guard let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
                print(url)
                subject.send([url])
                
            }
        }
        return subject.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
}

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
