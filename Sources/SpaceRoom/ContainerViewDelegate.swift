//
//  ContainerViewDelegate.swift
//  SpaceRoom
//
//  Created by windy on 2025/8/27.
//

import UIKit

public protocol ContainerViewDelegate: UIViewController {
    associatedtype Index: ContainerViewIndex
    
    func containerContentRoot(_ container: Self) -> Index
    func container(_ container: Self, contentAtIndex index: Index) -> Content
    func container(_ container: Self, contentConfiguraionWithContent content: UIViewController, index: Index)
    
    func containerShouldSlideModeOn(_ container: Self) -> Bool
    func container(_ container: Self, slideProgressWithFactor factor: CGFloat, tendTo: Index, translation: CGFloat)
    func container(_ container: Self, slideDidChangeWithOld old: Index, new: Index)
    
    func container(_ container: Self, visualContentByKind kind: Kind) -> VisualContent?
    func container(_ container: Self, visualChangeProgressWithFactor factor: CGFloat, tendTo: Kind, translation: CGFloat)
    func container(_ container: Self, visualDidChangeWithKind kind: Kind)
    func container(_ container: Self, visualResetChangeWith isDidChange: Bool, kind: Kind)

}

extension ContainerViewDelegate {
    public typealias Kind = ContentVisualContentKind
    public typealias Content = UIViewController
    public typealias VisualContent = UIView
}
