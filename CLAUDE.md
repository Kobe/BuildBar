# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BuildBar is a macOS menubar application built with SwiftUI that monitors GitHub Actions workflow runs. It displays the status of CI/CD pipelines directly in the menubar with color-coded icons and notifications for failures.

## Development Commands

Since this is an Xcode project, development is primarily done through Xcode IDE:

- **Build**: Use Xcode's Product → Build (⌘B) or `xcodebuild -scheme BuildBar build`
- **Run**: Use Xcode's Product → Run (⌘R) to launch the app
- **Test**: Use Xcode's Product → Test (⌘U) or `xcodebuild -scheme BuildBar test`
- **Clean**: Use Xcode's Product → Clean Build Folder (⌘⇧K)

## Architecture

### App Entry Point
- **BuildBarApp.swift**: MenuBarExtra-based app with icon animation for failures

### Views
- **ContentView.swift**: Menubar dropdown showing failing runs grouped by repository
- **Views/PreferencesView.swift**: Combined settings window with Workflows and Settings tabs
- **Views/RepoListView.swift**: Repository list in workflow configuration
- **Views/WorkflowListView.swift**: Workflow selection checkboxes

### Models
- **PipelineModel.swift**: Pipeline, PipelineStatus, PipelineStore (state management with polling)
- **Models/GitHubModels.swift**: GitHub API DTOs (User, Repository, Workflow, WorkflowRun)
- **Models/AppSettings.swift**: PollingInterval enum and AppSettings with @AppStorage

### ViewModels
- **ViewModels/SettingsViewModel.swift**: Token management and validation
- **ViewModels/RunConfigViewModel.swift**: Repository and workflow loading

### Services
- **Services/GitHubService.swift**: GitHub REST API client implementing PipelineService
- **Services/KeychainService.swift**: Secure PAT storage using Keychain
- **Services/NotificationService.swift**: System notifications and sound alerts

### Utilities
- **Utilities/AccessibleColors.swift**: WCAG 2.2 AA compliant color palette
- **Utilities/MenubarIconAnimator.swift**: Timer-based icon blinking

## Key Design Decisions

- **Protocol-based services**: `PipelineService` protocol allows mocking for tests
- **@MainActor isolation**: All UI state uses MainActor for thread safety
- **Menubar-only**: LSUIElement=true hides dock icon
- **Keychain storage**: GitHub PAT stored securely, never in UserDefaults
- **WCAG 2.2 AA colors**: All status colors meet 4.5:1 contrast ratio

## Testing

47 unit tests covering:
- Pipeline model and status logic
- GitHub model JSON decoding
- AppSettings and PollingInterval
- PipelineStore refresh, polling, and failure detection