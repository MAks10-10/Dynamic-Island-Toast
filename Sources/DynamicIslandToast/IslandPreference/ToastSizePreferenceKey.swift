//
//
// ToastSizePreferenceKey.swift
// DynamicIslandToast
//
// Created by Shubh Magdani 
//

import SwiftUI

public struct ToastSizePreferenceKey: PreferenceKey {
    public static let defaultValue: CGSize = .zero
    
    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
