//
//  ViewController.swift
//  SpaceRoom-Example
//
//  Created by windy on 2025/8/24.
//

import UIKit
import Yang
import SpaceRoom
import ScrollableSegment

//enum Index: Int, CaseIterable, ContainerViewIndex {
//    case yellow, red, purple
//}

enum Index: Int, CaseIterable, ContainerSlideDiretionIndex {
    case yellow, red, purple
    
    public var loopPreview: Self {
        let value = self.rawValue - 1
        return .init(rawValue: value) ?? .purple
    }
    
    public var loopNext: Self {
        let value = self.rawValue + 1
        return .init(rawValue: value) ?? .yellow
    }
    
    public var title: String {
        switch self {
        case .yellow: return "Yellow"
        case .red:    return "Red"
        case .purple: return "Purple"
        }
    }
}

class ViewController: ContainerViewController<Index> {
    
    public lazy var segment: ScrollableSegmentView = .init(
        frame: .zero,
        configuration: {
            var configs = ScrollableSegmentViewConfiguration(count: Index.allCases.count)
//            configs.current = 1
            configs.itemOffset = 16
            configs.itemSpacing = 12
            configs.itemScaleFactor = 1.15
            configs.isShowMarkItem = false
            return configs
        }()
    ) { configs, index in
        let factor = configs.itemScaleFactor
        let view = ScrollableSegmentTextItem()
        view.set(
            text: Index(rawValue: index)!.title,
            font: .systemFont(ofSize: 22 * factor, weight: .semibold)
        )
        return view
    } itemWidthProvider: { segment, item in
        item.size().width
    } currentChange: { [weak self] segment, old, new in
        self?.selectedContent(at: .init(rawValue: new)!)
        print(#function, #line, old, new)
    }
    
    public var mode: Index {
        get { .init(rawValue: segment.currentMode) ?? .yellow }
        set { segment.currentMode = newValue.rawValue }
    }
    
    var timer: Timer?
    var progress: CGFloat = 0

    deinit {
        timer?.invalidate()
        timer = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .darkGray
        
        segment.yang.addToParent(view)
        segment.selectedMode(mode.rawValue)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.setNeedsUpdateConstraints()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let interval = 0.05
//        timer = .scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
//            guard let self else { return }
//            let tendTo = self.mode.loopNext
//            self.segment.progress(self.progress, tendToMode: tendTo.rawValue)
//            self.progress += interval * 0.4
//            if self.progress > 1 {
//                self.progress = 0
//                self.mode = self.mode.loopNext
//            }
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        timer?.invalidate()
        timer = nil
    }
    
    override func updateViewConstraints() {
        
        segment.yangbatch.remake { make in
            make.horizontal.equalToParent().offsetEdge(16)
            make.height.equal(to: 50)
            make.top.equalToParent(.topMargin)
        }
        
        super.updateViewConstraints()
    }
    
    
    override func containerContentRoot(_ container: ContainerViewController<Index>) -> Index {
        
        .yellow
    }
    
    override func container(_ container: ContainerViewController<Index>, contentAtIndex index: Index) -> Content {

        switch index {
        case .yellow: return YellowController()
        case .red:    return RedController()
        case .purple: return PurpleController()
        }
    }
    
    override func containerShouldSlideModeOn(_ container: ContainerViewController<Index>) -> Bool {
        
        true
    }
    
    override func container(_ container: ContainerViewController<Index>, slideProgressWithFactor factor: CGFloat, tendTo: Index, translation: CGFloat) {
        
        self.segment.progress(factor, tendToMode: tendTo.rawValue)
    }
    
    override func container(_ container: ContainerViewController<Index>, slideDidChangeWithOld old: Index, new: Index) {
        
        self.mode = new
    }
    
}

