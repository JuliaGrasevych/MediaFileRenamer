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
    @State var selectedObject: FileModel?
    
    var body: some View {
        ItemsListView(sections: viewModel.sections, selectedObject: $selectedObject)
            .onDrop(of: [ListViewModel.dropFileType], isTargeted: nil) { itemsProviders -> Bool in
                return self.viewModel.handleDrop(itemsProviders: itemsProviders)
        }
        .onReceive(notificationCenter.publisher(for: .add)) { _ in self.handleMenuAdd() }
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
}
