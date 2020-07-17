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
            Text("Filename: \(file.filename)")
//            Text("New name: \(file.filename)").opacity(file.name == "1" ? 1 : 0)
        }
    }
}
