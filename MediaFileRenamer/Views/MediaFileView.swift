//
//  MediaFileView.swift
//  MediaFileRenamer
//
//  Created by Iuliia Grasevych on 05.05.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import SwiftUI

struct MediaFileView: View {
    var file: FileViewModel
    @Binding var selectedItems: Set<FileID>
    var isSelected: Bool {
        selectedItems.contains(file.fileId)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(file.mediaInfo.title ?? "No title".uppercased())
            Text("Filename: \(file.initialFilename)")
            file.proposedFilename.map { proposedFilename in
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
                self.selectedItems.remove(self.file.fileId)
            } else {
                self.selectedItems.insert(self.file.fileId)
            }
        }
    }
}

extension FileViewModel {
    var initialFilename: String {
        return file.filename
    }
    
    var mediaInfo: MediaInfo {
        return file.mediaInfo
    }
}
