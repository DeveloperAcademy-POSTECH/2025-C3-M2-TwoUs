//
//  EKO_iOSApp.swift
//  EKO-iOS
//
//  Created by mini on 5/27/25.
//

import SwiftUI

@main
struct EKO_iOSApp: App {
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .environmentObject(coordinator)
        }
    }
}
