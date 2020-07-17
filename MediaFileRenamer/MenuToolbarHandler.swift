//
//  MenuToolbarHandler.swift
//  MediaFileRenamer
//
//  Created by Iuliia Grasevych on 17.07.2020.
//  Copyright © 2020 Iuliia Grasevych. All rights reserved.
//

import SwiftUI

final class MenuToolbarHandler {
    private static let notificationCenter = NotificationCenter.default
    static func add() {
        notificationCenter.post(name: .add, object: nil)
    }
}
