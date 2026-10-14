//
//
// DynamicIslandPassthroughWindow.swift
// DynamicIslandToast
//
// Created by Shubh Magdani 
//

import UIKit

public class DynamicIslandPassthroughWindow : UIWindow {
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) , let rootview = rootViewController?.view else {
            return nil
        }
        if #available(iOS 26, *) {
            if rootview.layer.hitTest(point)?.name == nil {
                return rootview
            }
        }else {
            if #available(iOS 18, *) {
                for subviews in rootview.subviews.reversed() {
                    let pointInSubview = subviews.convert(point, from: rootview)
                    if subviews.hitTest(pointInSubview, with: event) != nil {
                        return hitView
                    }
                }
            }else {
                return hitView == rootview ? nil : hitView
            }
        }
        return nil
    }
}
