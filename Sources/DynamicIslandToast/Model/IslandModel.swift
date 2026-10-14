//
//
// IslandModel.swift
// DynamicIslandToast
//
// Created by Shubh Magdani 
//
import Foundation


public struct IslandModel : Equatable  {
    let id: UUID = UUID()
    let type: ToastType
    let title : String
    let message : String
    public init(type: ToastType, title: String, message: String) {
        self.type = type
        self.title = title
        self.message = message
    }
}
