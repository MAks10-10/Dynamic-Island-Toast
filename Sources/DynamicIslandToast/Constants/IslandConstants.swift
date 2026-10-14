//
//
// IslandConstants.swift
// DynamicIslandToast
//
// Created by Shubh Magdani 
//


import Foundation
import SwiftUI

public enum DynamicIslandMetrics {
    static let width: CGFloat = 124 // 126 is orignal taking smaller value
    static let height: CGFloat = 36 // 37.33 is orignal taking smaller value
    static let cornerRadius: CGFloat = height / 2
    static let topInset: CGFloat = 11 // for the capsule of dynamic island
    
    static let dynamicIslandCornerRadius: CGFloat = 40
    static let expandedHorizontalPadding: CGFloat = 40
}

public enum ToastType: Equatable {
    case success
    case error
    case info
    case warning
    case custom(color : Color , icon : String)

    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        case .warning: return .orange
        case .custom(color: let color , _) : return color
        }
    }

    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .custom(color: _ , let icon) : return icon
        }
    }
}

public enum ScreenType {
    case plain          // Home button devices (SE, 8 and earlier)
    case notch          // iPhone X–13 series, and non-Pro 14/16e
    case dynamicIsland  // iPhone 14 Pro and later Pro/Plus/standard models with the island

    static func current(safeAreaTop: CGFloat) -> ScreenType {
        switch safeAreaTop {
        case ..<24:
            return .plain
        case 24..<55:
            return .notch
        default:
            return .dynamicIsland
        }
    }
    
}
