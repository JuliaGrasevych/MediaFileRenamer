//
//  FileViewModel.swift
//  MediaFileRenamer
//
//  Created by Julia on 27.07.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import Foundation

struct FileViewModel: Identifiable {
    
    enum ViewError: Hashable {
        case error(String), noError
        
        var text: String? {
            switch self {
            case .error(let text): return text
            case .noError: return nil
            }
        }
    }
    
    let file: FileModel
    var proposedFilename: String?
    var error: ViewError
    
    var fileId: FileID { file.url }
    
    var id: String {
        fileId.identityString + (proposedFilename ?? "") + (error.text ?? "")
    }
    
    init(_ file: FileModel, proposedFilename: String? = nil, error: ViewError = .noError) {
        self.init(file)
        self.proposedFilename = proposedFilename
        self.error = error
    }
    
    init(_ file: FileModel) {
        self.file = file
        self.proposedFilename = nil
        self.error = .noError
    }
}

extension FileViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(file)
        hasher.combine(proposedFilename)
        hasher.combine(error)
    }
}

extension FileViewModel: Equatable {
    static func == (lhs: FileViewModel, rhs: FileViewModel) -> Bool {
        return lhs.file == rhs.file
            && lhs.proposedFilename == rhs.proposedFilename
            && lhs.error == rhs.error
    }
}
