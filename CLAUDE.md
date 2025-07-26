# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BuildBar is a macOS menubar application built with SwiftUI to visualize the status of CI/CD pipelines. The project follows the standard iOS/macOS app structure using Xcode.

## Development Commands

Since this is an Xcode project, development is primarily done through Xcode IDE:

- **Build**: Use Xcode's Product → Build (⌘B) or build from command line with `xcodebuild`
- **Run**: Use Xcode's Product → Run (⌘R) to launch the app
- **Test**: Use Xcode's Product → Test (⌘U) for running unit tests
- **Clean**: Use Xcode's Product → Clean Build Folder (⌘⇧K)

## Architecture

- **BuildBarApp.swift**: Main app entry point using SwiftUI's `@main` attribute
- **ContentView.swift**: Primary view currently showing placeholder content
- **Assets.xcassets/**: App icons and color assets
- Project uses SwiftUI for the user interface framework
- Standard iOS/macOS app architecture with separation of app lifecycle and views

## Key Files

- `BuildBar.xcodeproj/`: Xcode project configuration
- `BuildBar/`: Main source directory containing Swift files
- `LICENSE`: Project license file
- `README.md`: Basic project description

## Development Notes

This is a fresh SwiftUI project with minimal implementation. The ContentView currently displays placeholder content that will need to be replaced with actual CI/CD pipeline visualization functionality.