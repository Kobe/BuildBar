//
//  MenubarController.swift
//  BuildBar
//
//  Manages NSStatusItem with full-color icon rendering (isTemplate = false).
//

import AppKit
import SwiftUI
import Combine

@MainActor
final class MenubarController: NSObject {
    private let statusItem: NSStatusItem
    private let popover: NSPopover
    private let store: PipelineStore
    private let animator: MenubarIconAnimator
    private var cancellables = Set<AnyCancellable>()

    init(pipelineStore: PipelineStore, iconAnimator: MenubarIconAnimator) {
        self.store = pipelineStore
        self.animator = iconAnimator
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()

        super.init()

        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: ContentView().environmentObject(pipelineStore)
        )

        if let button = statusItem.button {
            button.action = #selector(handleClick)
            button.target = self
        }

        // Keep animator in sync with failure count
        store.$pipelines
            .map { $0.filter { $0.status == .failed }.count }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in self?.animator.updateFailureCount(count) }
            .store(in: &cancellables)

        // Redraw icon whenever pipelines or blink state changes
        store.$pipelines
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.syncIcon() }
            .store(in: &cancellables)

        animator.$isVisible
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.syncIcon() }
            .store(in: &cancellables)

        syncIcon()
    }

    @objc private func handleClick() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    private func syncIcon() {
        guard let button = statusItem.button else { return }
        let failedCount = store.failedCount

        // Blink: hide icon during off-phase
        if !animator.isVisible && AppSettings.shared.animateMenubarIcon && failedCount > 0 {
            button.image = nil
            button.attributedTitle = NSAttributedString(string: "")
            return
        }

        let (symbol, color) = resolveAppearance(failedCount: failedCount)
        button.image = coloredSymbol(named: symbol, color: color)

        if failedCount > 0 {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.boldSystemFont(ofSize: 10),
                .foregroundColor: NSColor(Color.buildBarRed)
            ]
            button.attributedTitle = NSAttributedString(string: " \(failedCount)", attributes: attrs)
            button.imagePosition = .imageLeft
        } else {
            button.attributedTitle = NSAttributedString(string: "")
            button.imagePosition = .imageOnly
        }
    }

    private func resolveAppearance(failedCount: Int) -> (String, NSColor) {
        if failedCount > 0 { return ("xmark.circle.fill", NSColor(Color.buildBarRed)) }
        switch store.overallStatus {
        case .success: return ("checkmark.circle.fill",                     NSColor(Color.buildBarGreen))
        case .failed:  return ("xmark.circle.fill",                         NSColor(Color.buildBarRed))
        case .running: return ("arrow.triangle.2.circlepath.circle.fill",   NSColor(Color.buildBarBlue))
        case .pending: return ("clock.circle.fill",                         NSColor(Color.buildBarOrange))
        }
    }

    private func coloredSymbol(named symbolName: String, color: NSColor) -> NSImage {
        let sizeConfig = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let colorConfig = NSImage.SymbolConfiguration(paletteColors: [color])
        let config = sizeConfig.applying(colorConfig)
        let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?
            .withSymbolConfiguration(config) ?? NSImage()
        image.isTemplate = false
        return image
    }
}
