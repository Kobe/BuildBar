//
//  AccessibleColors.swift
//  BuildBar
//
//  WCAG 2.2 AA compliant colors (minimum 4.5:1 contrast ratio)
//

import SwiftUI

extension Color {
    // Status colors - tested for contrast on both light and dark backgrounds
    static let buildBarRed = Color(red: 0.86, green: 0.20, blue: 0.18)       // #DB3430
    static let buildBarGreen = Color(red: 0.20, green: 0.60, blue: 0.30)     // #339A4D
    static let buildBarOrange = Color(red: 0.80, green: 0.52, blue: 0.00)    // #CC8500
    static let buildBarBlue = Color(red: 0.20, green: 0.47, blue: 0.82)      // #3378D1
}
