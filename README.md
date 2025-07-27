# BuildBar 🔨

[![macOS](https://img.shields.io/badge/macOS-15.0+-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-green.svg)](https://developer.apple.com/xcode/swiftui/)

A macOS menubar application to visualize the status of your CI/CD pipelines, built as part of a **Claude Code challenge**.

> **⚠️ Disclaimer**: This project was developed by someone with **zero Swift or macOS development experience** using Claude Code as a learning companion. It serves as an exploration of SwiftUI and macOS development concepts.

## 🎯 Challenge Goals

- [x] Convert a standard SwiftUI app to a menubar-only application
- [ ] Implement CI/CD pipeline status monitoring
- [ ] Create an intuitive status visualization system
- [ ] Learn Swift and SwiftUI fundamentals through AI assistance

## 🚀 Current Status

The app has been successfully converted from a standard windowed application to a menubar-only app. Key accomplishments:

- ✅ MenuBarExtra implementation with hammer icon
- ✅ LSUIElement configuration to hide from dock
- ✅ Basic menubar interface with quit functionality
- ✅ Proper project structure and Info.plist setup

## 🛠 Development

This is an Xcode project using SwiftUI for macOS 15.0+:

```bash
# Build the project
xcodebuild

# Or use Xcode
# Product → Build (⌘B)
# Product → Run (⌘R)
```

## 📁 Project Structure

```
BuildBar/
├── BuildBar/
│   ├── BuildBarApp.swift      # Main app entry point with MenuBarExtra
│   ├── ContentView.swift      # Menubar content view
│   ├── Info.plist            # App configuration with LSUIElement
│   └── Assets.xcassets/      # App icons and assets
└── BuildBar.xcodeproj/       # Xcode project files
```

## 🎯 Next Steps

- [ ] Integrate with popular CI/CD platforms (GitHub Actions, Jenkins, etc.)
- [ ] Design status indicators and notification system
- [ ] Implement real-time pipeline monitoring
- [ ] Add configuration UI for pipeline endpoints
- [ ] Create status history and logging

## 🤖 Built with Claude Code

This project showcases the power of AI-assisted development, demonstrating how someone without domain expertise can learn and build native applications with the right AI companion.

---

*"Learning Swift and macOS development, one commit at a time."*
