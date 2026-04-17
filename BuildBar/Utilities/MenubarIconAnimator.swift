//
//  MenubarIconAnimator.swift
//  BuildBar
//
//  Timer-based blinking animation for menubar icon
//

import SwiftUI
import Combine
import Foundation

@MainActor
class MenubarIconAnimator: ObservableObject {
    @Published var isVisible: Bool = true
    @Published private(set) var isAnimating: Bool = false

    private var timer: Timer?
    private var failureCount: Int = 0

    var shouldAnimate: Bool {
        AppSettings.shared.animateMenubarIcon && failureCount > 0
    }

    func updateFailureCount(_ count: Int) {
        let wasAnimating = failureCount > 0
        failureCount = count

        if count > 0 && !wasAnimating {
            startAnimation()
        } else if count == 0 && wasAnimating {
            stopAnimation()
        }
    }

    func startAnimation() {
        guard !isAnimating else { return }
        guard AppSettings.shared.animateMenubarIcon else { return }

        isAnimating = true
        isVisible = true

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.isVisible.toggle()
            }
        }
    }

    func stopAnimation() {
        timer?.invalidate()
        timer = nil
        isAnimating = false
        isVisible = true
    }

    func acknowledgeFailures() {
        stopAnimation()
    }
}
