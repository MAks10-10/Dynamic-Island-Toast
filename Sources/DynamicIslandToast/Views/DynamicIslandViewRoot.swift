//
//
// DynamicIslandViewRoot.swift
// DynamicIslandToast
//
// Created by Shubh Magdani 
//


import SwiftUI


public struct DynamicIslandViewRoot: View {
    @ObservedObject var manager = DyanmicIslandToastManager.shared
    @State private var measuredContentSize: CGSize = .zero
    @State private var dragOffset: CGFloat = 0
    @State private var lastDragUpdate: Date = .distantPast

    public var body: some View {
        GeometryReader { proxy in
            let safeArea = proxy.safeAreaInsets
            let screenType = ScreenType.current(safeAreaTop: safeArea.top)
            let progress = min(abs(dragOffset) / 20, 1)
            Group{
                switch screenType {
                case .dynamicIsland:
                    islandToast(proxy: proxy , progress : progress)
                case .notch :
                    islandToast(proxy: proxy , progress : progress , isNotch: true)
                case .plain:
                    bannerToast(safeAreaTop: safeArea.top)
                }
            }
            .statusBarHidden(screenType != .plain && manager.isPresented)
        }
        
        .onChange(of: manager.isPresented) { _ , newValue in
            if newValue { dragOffset = 0 }
        }
    }

    // Only reacts to upward movement — a downward drag is clamped to 0 and does nothing.
    private var dismissDragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                        let now = Date()
                        guard now.timeIntervalSince(lastDragUpdate) > 1.0 / 60.0 else { return }
                        lastDragUpdate = now

                        let translation = value.translation.height
                        let clamped = max(min(translation, 0), -100)

                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            dragOffset = clamped
                        }
                    }
            .onEnded { value in
                let dismissThreshold: CGFloat = -40
                if value.translation.height < dismissThreshold {
                    withAnimation(.bouncy(duration: 0.3)) {
                        dragOffset = -200
                    }
                    manager.dismiss()
                } else {
                    withAnimation(.bouncy(duration: 0.3)) {
                        dragOffset = 0
                    }
                }
            }
    }

    // MARK: - Dynamic Island variant (existing pill morph)
    @ViewBuilder
    private func islandToast(proxy: GeometryProxy , progress : CGFloat , isNotch : Bool = false) -> some View {
        let size = proxy.size
        let safeArea = proxy.safeAreaInsets
        let offset: CGFloat = max(safeArea.top - 48, 0)
        let isExpanded = manager.isPresented
        let expandedWidth = isNotch ? size.width : (size.width - DynamicIslandMetrics.expandedHorizontalPadding)
        let expandedHeight = max(measuredContentSize.height + 14, DynamicIslandMetrics.height)
       

        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: isNotch ? 20 : DynamicIslandMetrics.dynamicIslandCornerRadius)
                .fill(
                    islandFill
                )
                .overlay {
                    RoundedRectangle(
                        cornerRadius: isNotch ? 20 : DynamicIslandMetrics.dynamicIslandCornerRadius
                    )
                    .fill(.black.opacity(progress))
                }
                .frame(
                    width: isExpanded ? expandedWidth : DynamicIslandMetrics.width,
                    height: isExpanded ? expandedHeight : DynamicIslandMetrics.height
                )
                .overlay(alignment: .top) {
                    if isExpanded, let toast = manager.currentToast {
                        toastContent(toast)
                            .padding(.top, 25)
                            .fixedSize(horizontal: false, vertical: true)
                            .background(
                                GeometryReader { contentProxy in
                                    Color.clear
                                        .preference(key: ToastSizePreferenceKey.self, value: contentProxy.size)
                                }
                            )
                            .offset(y: max(dragOffset , -5))
                            .blur(radius: (progress * 10).rounded(.toNearestOrAwayFromZero))
//                            .opacity(1 - progress)
                            .gesture(dismissDragGesture)
                            .transition(.blurReplace.combined(with: .scale(0.5)))
                    }
                }
                .onPreferenceChange(ToastSizePreferenceKey.self) { newSize in
                    measuredContentSize = newSize
                }
        }
        .clipped()
        .geometryGroup()
        .frame(maxWidth: .infinity)
        .offset(y: offset)
        .ignoresSafeArea()
        .animation(.bouncy(duration: 0.4), value: isExpanded)
        .animation(.bouncy(duration: 0.4), value: expandedHeight)
    }
    

    // MARK: - Notch/plain variant (slide-down banner)
    @ViewBuilder
    private func bannerToast(safeAreaTop: CGFloat) -> some View {
        let isExpanded = manager.isPresented

        ZStack {
            if let toast = manager.currentToast {
                toastContent(toast)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                islandFill
                            )
                    )
            }
        }
        .opacity(isExpanded ? 1 : 0)
        .scaleEffect(isExpanded ? 1 : 0.92, anchor: .top)
        .offset(y: isExpanded ? max(dragOffset, -40) : -40)
        .gesture(dismissDragGesture)
        .padding(.horizontal, 16)
        .padding(.top, max(safeAreaTop - 8, 8))
        .frame(maxWidth: .infinity, alignment: .top)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.4), value: isExpanded)
    }

    private var islandFill: LinearGradient {
        if let tintColor = manager.currentToast?.type.color {
            let tint : Color = (manager.isPresented && manager.isGradientNeeded) ? tintColor : .black
            return LinearGradient(
                colors: [.black , tint],
                startPoint: .center,
                endPoint: .bottom
            )
        }
           return LinearGradient(
               colors: [.black ],
               startPoint: .center,
               endPoint: .bottom
           )
       }
    @ViewBuilder
    private func toastContent(_ toast: IslandModel) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: toast.type.icon)
                .font(.largeTitle)
                .foregroundStyle(.white, toast.type.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(toast.title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Text(toast.message)
                    .font(.subheadline)
                    .lineLimit(4)
                    .foregroundStyle(.white.opacity(0.9))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}
