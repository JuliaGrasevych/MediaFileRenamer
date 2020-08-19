//
//  ContentView.swift
//  MediaFileRenamer
//
//  Created by Iuliia Grasevych on 05.05.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var viewModel: ListViewModel
    let notificationCenter = NotificationCenter.default
    @State var selectedItems = Set<FileID>()
    var isReadyToRename: Bool {
        return viewModel.objects
            .filter { obj in selectedItems.contains { obj.fileId == $0 } }
            .contains(where: { $0.proposedFilename != nil })
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("\(selectedItems.count) file(s) selected")
                    .padding()
                    .frame(alignment: .leading)
                HStack {
                    Button(action: {
                        self.displayRenameDialog()
//                        self.viewModel.preview(items: Array(self.selectedItems))
                    }) {
                        Text("Rename")
                    }
                    .disabled(selectedItems.isEmpty)
                    
                    Button(action: {
                        self.viewModel.rename(items: Array(self.selectedItems))
                    }) {
                        Text("Ok")
                    }
                    .disabled(selectedItems.isEmpty || !isReadyToRename)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            ItemsListView(sections: viewModel.sections, selectedItems: $selectedItems)
                .onDrop(of: [ListViewModel.dropFileType], isTargeted: nil) { itemsProviders -> Bool in
                    return self.viewModel.handleDrop(itemsProviders: itemsProviders)
            }
            .onReceive(notificationCenter.publisher(for: .add)) { _ in self.handleMenuAdd() }
            .onReceive(notificationCenter.publisher(for: .delete), perform: { _ in
                self.viewModel.delete(items: Array(self.selectedItems))
                self.selectedItems = []
            })
            .onReceive(notificationCenter.publisher(for: .selectAll), perform: { _ in
                self.selectedItems.formUnion(Set(self.viewModel.objects.map(\.fileId)))
            })
        }
    }
    
    private func handleMenuAdd() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = URL.supportedAudioTypes
        openPanel.begin { result in
            guard result == .OK else { return }
            self.viewModel.handleAdd(urls: openPanel.urls)
        }
    }

    private func displayRenameDialog() {
        
    }
}
