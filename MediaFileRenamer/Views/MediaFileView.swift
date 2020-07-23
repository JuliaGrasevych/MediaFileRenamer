//
//  MediaFileView.swift
//  MediaFileRenamer
//
//  Created by Iuliia Grasevych on 05.05.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import SwiftUI

struct MediaFileView: View {
    @ObservedObject var file: FileModel
    @Binding var selectedItems: Set<FileModel>
    var isSelected: Bool {
        selectedItems.contains(file)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(file.mediaInfo.title ?? "No title".uppercased())
            Text("Filename: \(file.initialFilename())")
            file.proposedFilename().map { proposedFilename in
                HStack {
                    Text("􀄵")
                    Text(proposedFilename)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(isSelected ? 1.0 : 0.4))
        .cornerRadius(6)
        .onTapGesture {
            if self.isSelected {
                self.selectedItems.remove(self.file)
            } else {
                self.selectedItems.insert(self.file)
            }
        }
    }
}

extension FileModel {
    func initialFilename() -> String {
        switch filename {
        case let .initial(name): return name
        case let .renaming(name, _): return name
        }
    }
    
    func proposedFilename() -> String? {
        switch filename {
        case .initial: return nil
        case let .renaming(_, name): return name
        }
    }
}
