//
//  MediaFileView.swift
//  MediaFileRenamer
//
//  Created by Iuliia Grasevych on 05.05.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import SwiftUI

struct MediaFileView: View {
    var file: FileModel
    var body: some View {
        VStack(alignment: .leading) {
            Text(file.mediaInfo.title ?? "No title".uppercased())
            Text("Filename: \(file.initialFilename())")
            file.proposedFilename().map { proposedFilename in
                HStack {
                    Image("arrow.turn.down.right")
                    Text(proposedFilename)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.6))
        .cornerRadius(6)
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
