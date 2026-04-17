//
//  NotificationService.swift
//  BuildBar
//
//  Sound playback and system notifications
//

import Foundation
import UserNotifications
import AppKit

class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func playSound(named soundName: String) {
        if let sound = NSSound(named: NSSound.Name(soundName)) {
            sound.play()
        }
    }

    func requestPermissions() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    func showNotification(title: String, body: String, workflowUrl: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        if let urlString = workflowUrl {
            content.userInfo = ["url": urlString]
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    func notifyFailure(workflowName: String, repoName: String, url: String?) {
        let settings = AppSettings.shared

        if settings.playSoundOnFailure {
            playSound(named: settings.failureSoundName)
        }

        if settings.showSystemNotification {
            showNotification(
                title: "Build Failed",
                body: "\(workflowName) in \(repoName)",
                workflowUrl: url
            )
        }
    }
}
