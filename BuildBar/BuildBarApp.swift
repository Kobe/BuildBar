//
//  BuildBarApp.swift
//  BuildBar
//
//  Created by Kobe on 7/26/25.
//

import SwiftUI

@main
struct BuildBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Window("BuildBar Preferences", id: "preferences") {
            PreferencesView()
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menubarController: MenubarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        menubarController = MenubarController(
            pipelineStore: PipelineStore(),
            iconAnimator: MenubarIconAnimator()
        )
    }
}
