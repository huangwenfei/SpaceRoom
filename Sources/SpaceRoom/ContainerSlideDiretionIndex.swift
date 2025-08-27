//
//  ContainerSlideDiretionIndex.swift
//  SpaceRoom
//
//  Created by windy on 2025/8/24.
//

import Foundation

public protocol ContainerSlideDiretionIndex: ContainerViewIndex, CaseIterable {
    var indexPath: Int { get }
    var preview: Self? { get }
    var next: Self? { get }
}

internal extension ContainerSlideDiretionIndex {
    
    static var first: Self? { allCases.first }
    static var last: Self? { Array(allCases).last }
    
    var first: Self? { Self.first }
    var last: Self? { Self.last }
    
    static func equal(lhs: Self, rhs: Self) -> Bool {
        lhs == rhs
    }
    
    func equal(to other: Self) -> Bool {
        self == other
    }
    
    func isEqualToFirst() -> Bool {
        self == first
    }
    
    func isEqualToLast() -> Bool {
        self == last
    }
    
}

extension ContainerSlideDiretionIndex where Self: RawRepresentable, Self.RawValue == Int {
    
    public var indexPath: Int {
        rawValue
    }
    
    public var preview: Self? {
        .init(rawValue: self.rawValue - 1)
    }
    
    public var next: Self? {
        .init(rawValue: self.rawValue + 1)
    }
    
}
