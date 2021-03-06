//
//  ItemsListView.swift
//  MediaFileRenamer
//
//  Created by Iuliia Grasevych on 07.05.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import SwiftUI

struct ItemsListView: View {
    var sections: [ArtistSection]
    @Binding var selectedItems: Set<FileID>
    
    var body: some View {
        List(sections.sorted(by: { $0.id > $1.id }), selection: $selectedItems) { item in
            VStack(alignment: .leading) {
                Section(header: Text(item.id)
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.all)
                ) {
                    VStack(alignment: .leading) {
                        ForEach(item.items) { song in
                            MediaFileView(file: song, selectedItems: self.$selectedItems)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}
