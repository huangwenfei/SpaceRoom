//
//  ContentScrollView.swift
//  SpaceRoom
//
//  Created by windy on 2025/8/24.
//

#if false
import UIKit

open class ContentScrollView: UIView {
    
    // MARK: Layer
    public override class var layerClass: AnyClass {
        CAScrollLayer.self
    }
    
    private var scrollLayer: CAScrollLayer {
        self.layer as! CAScrollLayer
    }
    
    // MARK: Properties
    open var direction: Direction = .horizontally {
        didSet { scrollLayer.scrollMode = direction.layerMode }
    }
    
    open var contentOffset: CGPoint = .zero
    open var visibleRect: CGRect = .zero
    
    open private(set) lazy var contents: [UIView] = []
    
    // MARK: Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commit()
    }
    
    open func commit() {
        setupLayer()
        setupContents()
    }
    
    // MARK: Setups
    open func setupLayer() {
        scrollLayer.scrollMode = .horizontally
        
    }
    
    open func setupContents() {
        
    }
    
}

extension ContentScrollView {
    public enum Direction: Int, Hashable, Codable {
        case horizontally, vertically
        
        public var layerMode: CAScrollLayerScrollMode {
            switch self {
            case .horizontally: return .horizontally
            case .vertically:   return .vertically
            }
        }
    }
}
#endif
