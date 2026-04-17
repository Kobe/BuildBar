# BuildBar 🔨

[![macOS](https://img.shields.io/badge/macOS-15.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-green.svg)](https://developer.apple.com/xcode/swiftui/)

A macOS menubar application to monitor GitHub Actions workflow runs, built as part of a **Claude Code challenge**.

> **⚠️ Disclaimer**: This project was developed by someone with **zero Swift or macOS development experience** using Claude Code as a learning companion.

## Features

- **Menubar status icon** - Color-coded icon shows overall pipeline health at a glance
- **Blinking failure alert** - Icon blinks red with failure count when workflows fail
- **GitHub Actions integration** - Monitors workflow runs from repositories you have access to
- **Grouped failure view** - Failing runs grouped by repository in dropdown
- **Click to open** - Click any run to open it directly in GitHub
- **System notifications** - Get notified when a workflow newly fails
- **Configurable polling** - Choose refresh interval (30s, 1m, 5m, 15m)
- **Secure token storage** - GitHub PAT stored in macOS Keychain
- **WCAG 2.2 AA colors** - Accessible color palette with 4.5:1 contrast ratio

## Development

This is an Xcode project using SwiftUI for macOS 15.0+:

```bash
# Build
xcodebuild -scheme BuildBar build

# Test
xcodebuild -scheme BuildBar test

# Or use Xcode
# Product → Build (⌘B)
# Product → Run (⌘R)
# Product → Test (⌘U)
```

## Project Structure

```
BuildBar/
├── BuildBar/
│   ├── BuildBarApp.swift           # App entry point with MenuBarExtra
│   ├── ContentView.swift           # Menubar dropdown view
│   ├── PipelineModel.swift         # Pipeline model and store
│   ├── Info.plist                  # LSUIElement for menubar-only
│   ├── Models/
│   │   ├── GitHubModels.swift      # GitHub API DTOs
│   │   └── AppSettings.swift       # User preferences
│   ├── Views/
│   │   ├── PreferencesView.swift   # Settings window (tabs)
│   │   ├── RepoListView.swift      # Repository selection
│   │   └── WorkflowListView.swift  # Workflow checkboxes
│   ├── ViewModels/
│   │   ├── SettingsViewModel.swift # Token management
│   │   └── RunConfigViewModel.swift# Workflow loading
│   ├── Services/
│   │   ├── GitHubService.swift     # GitHub API client
│   │   ├── KeychainService.swift   # Secure storage
│   │   └── NotificationService.swift
│   ├── Utilities/
│   │   ├── AccessibleColors.swift  # WCAG AA colors
│   │   └── MenubarIconAnimator.swift
│   └── Assets.xcassets/
├── BuildBarTests/                  # 47 unit tests
└── BuildBar.xcodeproj/
```

## Setup

1. Open `BuildBar.xcodeproj` in Xcode
2. Build and run (⌘R)
3. Click the menubar icon → Preferences
4. Enter your GitHub Personal Access Token (needs `repo` scope)
5. Select which workflows to monitor

## Built with Claude Code

This project showcases AI-assisted development, demonstrating how someone without domain expertise can build native applications with the right AI companion.

---

*"Learning Swift and macOS development, one commit at a time."*
