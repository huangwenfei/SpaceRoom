//
//  ContentVisualViewController.swift
//  SpaceRoom
//
//  Created by windy on 2025/8/24.
//

import UIKit

public final class ContentVisualViewController: UIViewController {
    
    // MARK: Properties
    public var kind: ContentVisualContentKind = .header
    public var childView: UIView? = nil
    
    // MARK: Init
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let childView {
            view.addSubview(childView)
        }
    }
    
    // MARK: Layout
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        childView?.frame = view.bounds
    }
    
    // MARK: Setter
    public func set(child: UIView?, kind: ContentVisualContentKind) {
        self.kind = kind
        self.childView = child
    }
    
}

