//
//  FileViewModel.swift
//  MediaFileRenamer
//
//  Created by Julia on 27.07.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import Foundation

final class FileViewModel: Identifiable, ObservableObject {
    let file: FileModel
    var proposedFilename: String? {
        willSet {
            objectWillChange.send()
        }
    }
    var error: Error?
    
    var id: FileID { file.url }
    
    convenience init(_ file: FileModel, proposedFilename: String? = nil, error: Error? = nil) {
        self.init(file)
        self.proposedFilename = proposedFilename
        self.error = error
    }
    
    init(_ file: FileModel) {
        self.file = file
        self.proposedFilename = nil
        self.error = nil
    }
}

extension FileViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
    }
}

extension FileViewModel: Equatable {
    static func == (lhs: FileViewModel, rhs: FileViewModel) -> Bool {
        return lhs.file == rhs.file
    }
}
