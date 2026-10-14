//
//
// DyanmicIslandToastManager.swift
// DynamicIslandToast
//
// Created by Shubh Magdani 
//

import Combine
import SwiftUI


@MainActor
final public class DyanmicIslandToastManager: ObservableObject {
    public static let shared = DyanmicIslandToastManager()

    @Published private(set) var isPresented: Bool = false
    @Published private(set) var isGradientNeeded: Bool = true
    @Published private(set) var currentToast: IslandModel?
    @Published private(set) var currentDuration: TimeInterval = 2.5

    private var dismissTask: Task<Void, Never>?
    private var swapTask: Task<Void, Never>?

    private init() {}

    public func show(_ toast: IslandModel , duration: TimeInterval = 2.5 , isGradientNeeded : Bool = true) {
        let isFirstAttach = !DyanmicIslandWindowManager.shared.isAttached
        DyanmicIslandWindowManager.shared.attach()

        dismissTask?.cancel()
        swapTask?.cancel()

        let begin: () -> Void = { [self] in
            if isPresented {
                swapTask = Task {
                    withAnimation(.bouncy(duration: 0.35)) {
                        isPresented = false
                    }
                    try? await Task.sleep(for: .milliseconds(380))
                    guard !Task.isCancelled else { return }
                    presentNew(toast, duration: duration, gradientNeeded: isGradientNeeded)
                }
            } else {
                presentNew(toast, duration: duration , gradientNeeded: isGradientNeeded)
            }
        }

        if isFirstAttach {
            // Defer to the next run loop tick so the freshly mounted window
            // finishes its "collapsed" layout pass before we animate in.
            DispatchQueue.main.async {
                begin()
            }
        } else {
            begin()
        }
    }

    /// Manually dismiss the current toast (e.g. from an upward swipe).
    func dismiss() {
        guard isPresented else { return }
        dismissTask?.cancel()
        swapTask?.cancel()
        performDismiss()
    }

    private func presentNew(_ toast: IslandModel, duration: TimeInterval , gradientNeeded : Bool ) {
        currentToast = toast
        currentDuration = duration
        isGradientNeeded = gradientNeeded
        withAnimation(.bouncy(duration: 0.4)) {
            isPresented = true
        }

        dismissTask = Task {
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            performDismiss()
        }
    }

    /// Shared close + teardown sequence used by both the auto-timeout and
    /// the manual (drag-to-dismiss) paths.
    private func performDismiss() {
        withAnimation(.bouncy(duration: 0.4)) {
            isPresented = false
        }

        dismissTask = Task {
            // Wait for the collapse animation to finish before tearing
            // the window down. If a new toast interrupts (this task gets
            // cancelled by show()/swapTask), this never runs and the
            // window stays attached for the incoming toast.
            try? await Task.sleep(for: .milliseconds(400))
            guard !Task.isCancelled else { return }

            currentToast = nil
            DyanmicIslandWindowManager.shared.detach()
        }
    }
}
