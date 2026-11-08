# Accessibility

BuildBar is a small macOS menubar app that shows the status of GitHub Actions workflow runs. This page describes what the app currently does for accessibility, where it falls short, and how to report problems. It is based on the current source code, not on a formal audit.

## Accessibility priorities

**Target state:** WCAG 2.2 Level AA (applied to a native macOS app where the criteria fit) is the required minimum for every change. Level AAA is a bonus goal: meet AAA success criteria wherever feasible (for example enhanced contrast of 7:1 for text, 1.4.6; target size of at least 44 by 44 points, 2.5.5; no timing, 2.2.3; visible focus not obscured at all, 2.4.12), but missing AAA alone does not block a release. Conformance has not been formally audited yet; the Known barriers section lists where the project falls short of this target.

Current priorities:

1. Communicate build status without relying on color alone.
2. Make the menubar item, the dropdown, and the Preferences window usable with VoiceOver and the keyboard.
3. Respect macOS accessibility settings, especially Reduce Motion.
4. Keep the status colors readable on light and dark menubars.

## Supported environments

- macOS 15.0 or later (app deployment target), built with SwiftUI and AppKit (`NSStatusItem` + `NSPopover`).
- The Preferences window uses standard SwiftUI controls (`TabView`, `Form`, `Toggle`, `Picker`, `SecureField`, `List`), which inherit the built-in macOS accessibility behavior of those controls.
- No assistive technology (VoiceOver, Voice Control, Switch Control, Full Keyboard Access) has been tested with BuildBar so far.

What is in place today:

- A dedicated status palette in `BuildBar/Utilities/AccessibleColors.swift` (`buildBarRed`, `buildBarGreen`, `buildBarOrange`, `buildBarBlue`).
- The menubar icon uses a different SF Symbol per state (checkmark, xmark, circular arrows, clock), so the overall status is not conveyed by color alone. When runs fail, the failure count is shown next to the icon as text.
- In the Workflows tab, each workflow shows its status as text ("Passing", "Failing", "Running", "Pending") in addition to a colored dot.
- The icon blinks at 0.5 s intervals (one flash per second), below the WCAG three-flashes-per-second threshold. The blinking can be turned off in Settings > Notifications > "Animate menubar icon".
- Failure alerts are available through more than one channel: a sound (on by default, "Glass"), the blinking icon, and an optional system notification (off by default). Each can be toggled in Settings.
- The dropdown has keyboard shortcuts for Preferences (Cmd+,) and Quit (Cmd+Q).
- Text in the Preferences window uses semantic text styles (`.headline`, `.subheadline`, `.body`, `.caption`).

## Known barriers

These are known gaps, based on reading the code. They are open until fixed and documented here.

**Screen readers (VoiceOver)**

- No `accessibilityLabel`, `accessibilityHint`, or `accessibilityValue` is set anywhere in the app.
- The menubar icon is created with `accessibilityDescription: nil` (`MenubarController.swift`), so VoiceOver gets no name for the overall status. The failure count is exposed only as a bare number.
- During the "off" phase of the blink, the menubar button has no image and an empty title, so it momentarily has no content at all.
- The workflow checkboxes (`WorkflowListView.swift`) and the polling interval picker (`PreferencesView.swift`) use an empty label with `.labelsHidden()`, so VoiceOver announces them without a name.
- The colored status dots are not hidden from or described for assistive technology.

**Color and contrast**

- The colors in `AccessibleColors.swift` are documented as meeting 4.5:1, but this is not verified. Calculated against white (#FFFFFF) and a dark gray (#1E1E1E): red 4.64:1 / 3.59:1, green 3.62:1 / 4.61:1, orange 3.03:1 / 5.50:1, blue 4.42:1 / 3.77:1. None of the four colors reaches 4.5:1 on both backgrounds, and the colors do not adapt to light/dark mode or Increase Contrast.
- These colors are used for text in several places: error messages in the dropdown, the failure count in the menubar, the connection status in Settings, and the status text in the Workflows tab.
- In the repository list (`RepoListView.swift`), the aggregate status of each repository is shown only as a colored dot, with no text or shape alternative. Dropdown rows also use a colored dot, but they appear only under the "FAILING RUNS" heading.

**Motion**

- The blinking icon does not check the macOS Reduce Motion setting. It is on by default and keeps blinking until no failures remain or the user turns it off in Settings. `MenubarIconAnimator.acknowledgeFailures()` exists but is never called, so the blinking cannot be acknowledged.

**Text size and layout**

- The dropdown (`ContentView.swift`) and the menubar count use fixed point sizes (10 to 13 pt) and do not scale with system text size settings.
- The Preferences window has a fixed size of 700 x 500 pt.

**Keyboard**

- Keyboard-only operation has not been tested. In particular, it is not verified that the dropdown rows (plain-style buttons) can be reached and activated with the keyboard, or that the popover can be opened without a pointer.

**Notifications**

- `NotificationService.requestPermissions()` is never called, so it is not verified that system notifications (the non-audio, non-visual-icon alert channel) are delivered.

**Testing**

- The only accessibility-related tests (`BuildBarTests/PipelineStatusTests.swift`) check that each status maps to its palette color. There are no tests for contrast ratios, accessibility labels, or keyboard navigation, and no UI tests.

## Contributor expectations

When you change the UI:

- Give every interactive element and every meaningful image an accessible name. Do not use empty labels with `.labelsHidden()` without also setting `.accessibilityLabel`.
- Never use color as the only way to show status. Pair it with text, an SF Symbol shape, or an accessibility label.
- Use colors from `AccessibleColors.swift` for status, and check contrast for any change to that palette.
- Respect system settings: Reduce Motion for animation, semantic text styles instead of fixed point sizes where possible.
- Make new features usable with the keyboard alone.
- If possible, test the change with VoiceOver (Cmd+F5) and say in the pull request what you tested.
- Update this file when you fix a known barrier or introduce a new one.

## Reporting process

Report accessibility problems as an issue on [Kobe/BuildBar](https://github.com/Kobe/BuildBar/issues). **Every accessibility issue must have the `a11y` label** so it can be found and triaged. Please include:

- macOS version and BuildBar version or commit
- The assistive technology or system setting you use (for example VoiceOver, Reduce Motion, Increase Contrast)
- What you tried to do, what happened, and what you expected

## Ownership

BuildBar is maintained by Kobe (`@Kobe`), who is responsible for triaging accessibility issues and keeping this document current. BuildBar is a hobby project, so there is no guaranteed response time.

## Maintenance

- This document is reviewed whenever UI code changes, and the "Known barriers" list is updated as barriers are fixed or found.
- Claims on this page must be verifiable in the code or backed by documented testing. Conformance claims are only made after they have been tested.
- Last reviewed: November 2026.
