//
//
// DyanmicIslandWindowManager.swift
// DynamicIslandToast
//
// Created by Shubh Magdani 
//

import UIKit
import SwiftUI

@MainActor
public final class DyanmicIslandWindowManager {
    static let shared = DyanmicIslandWindowManager()

    static let windowTag = 999_002

    private var toastWindow: UIWindow?

    private init() {}

    var isAttached: Bool { toastWindow != nil }

    func attach() {
        if let window = toastWindow {
            window.isHidden = false
            return
        }

        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            ?? UIApplication.shared.connectedScenes.first as? UIWindowScene
        else { return }

        let window = DynamicIslandPassthroughWindow(windowScene: scene)
        window.tag = DyanmicIslandWindowManager.windowTag
        window.windowLevel = .alert + 1 // above sheets, fullScreenCovers, alerts
        window.backgroundColor = .clear
        window.isHidden = false

        let hostingController = UIHostingController(rootView: DynamicIslandViewRoot())
        hostingController.view.backgroundColor = .clear
        window.rootViewController = hostingController

        // Force an initial layout pass in the "collapsed" state right away,
        // so there's real starting geometry for SwiftUI to animate from
        // once isPresented flips to true.
        window.layoutIfNeeded()

        self.toastWindow = window
    }

    func detach() {
        toastWindow?.isHidden = true
    }

    func isWindowAttached(in scene: UIWindowScene) -> Bool {
        scene.windows.contains { $0.tag == DyanmicIslandWindowManager.windowTag }
    }
}
