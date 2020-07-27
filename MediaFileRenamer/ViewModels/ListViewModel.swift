//
//  ListViewModel.swift
//  MediaFileRenamer
//
//  Created by Iuliia Grasevych on 07.05.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import Foundation
import Combine

class ListViewModel: ObservableObject {
    static let dropFileType = kUTTypeFileURL as String
    static let unknownArtistSection = "Unknown artist"
    
    @Published private(set) var objects: Set<FileViewModel> = []
    private var dropCancellable: AnyCancellable?
    private var addCancellable: AnyCancellable?
    
    var sections: [ArtistSection] {
        return Dictionary(grouping: objects, by: \.file.mediaInfo.artist)
            .map { ArtistSection(id: $0.key ?? Self.unknownArtistSection, items: $0.value) }
    }
    
    func handleDrop(itemsProviders: [NSItemProvider]) -> Bool {
        if itemsProviders.isEmpty { return false }
        dropCancellable = FileDropHandler.handleDrop(itemsProviders: itemsProviders, fileType: Self.dropFileType)
            .flatMap { urls -> AnyPublisher<[FileViewModel], Never> in
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
    
    func preview(items: [FileID]) {
        print(items)
        
        objects.forEach { object in
            guard items.contains(object.id) else { return }
            guard let title = object.mediaInfo.title as? NSString else { return }
            object.proposedFilename = title.appendingPathExtension(object.file.extension)
        }
    }
    
    func rename(items: [FileID]) {
        objects.filter { items.contains($0.id) }
            .forEach { file in
                defer {
                    file.proposedFilename = nil
                }
                
                guard let proposedFilename = file.proposedFilename else { return }
                do {
                    try FileNameManager.rename(item: file.file, proposedFilename: proposedFilename)
                } catch let error {
                    file.error = error
                }
        }
    }
    
    private func fetchFiles(urls: [URL]) -> AnyPublisher<[FileViewModel], Never> {
        return Publishers.MergeMany(
            urls.map { FileFetcher.fetchFiles(at: $0)
                .map { items in items.map(FileViewModel.init) }
            }
        )
            .eraseToAnyPublisher()
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
