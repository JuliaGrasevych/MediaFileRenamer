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
    
    private var files: Set<FileModel> = [] {
        didSet {
            let newFiles = files.filter { !oldValue.contains($0) }.map(FileViewModel.init)
            var remainingObjects = objects.filter { file in files.contains(where: { file.fileId == $0.id }) }
            remainingObjects.append(contentsOf: newFiles)
            objects = remainingObjects
        }
    }
    @Published private(set) var objects: [FileViewModel] = []
    private var dropCancellable: AnyCancellable?
    private var addCancellable: AnyCancellable?
    
    var sections: [ArtistSection] {
        return Dictionary(grouping: objects, by: \.file.mediaInfo.artist)
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
                self.files.formUnion(files)
        }
        return true
    }
    
    func handleAdd(urls: [URL]) {
        addCancellable = fetchFiles(urls: urls)
            .sink(receiveValue: { files in
                if files.isEmpty { return }
                self.files.formUnion(files)
            })
    }
    
    func preview(items: [FileID]) {
        print(items)
        
        objects = objects.map { object -> FileViewModel in
            guard items.contains(object.fileId) else { return object }
            guard let title = object.mediaInfo.title as NSString? else { return object }
            return FileViewModel(object.file, proposedFilename: title.appendingPathExtension(object.file.extension))
        }
    }
    
    func rename(items: [FileID]) {
       objects = objects
            .map { file -> FileViewModel in
            guard items.contains(file.fileId) else { return file }
                guard let proposedFilename = file.proposedFilename else { return file }
                do {
                    let renamedFile = try FileNameManager.rename(item: file.file, proposedFilename: proposedFilename)
                    return FileViewModel(renamedFile, proposedFilename: nil)
                } catch let error {
                    return FileViewModel(file.file, proposedFilename: proposedFilename, error: .error(error.localizedDescription))
                }
        }
    }
    
    func delete(items: [FileID]) {
        files.subtract(files.filter { file in items.contains(where: { $0 == file.id }) })
    }
    
    private func fetchFiles(urls: [URL]) -> AnyPublisher<[FileModel], Never> {
        return Publishers.MergeMany(
            urls.map { FileFetcher.fetchFiles(at: $0) }
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
