//
//  ContainerViewController.swift
//  SpaceRoom
//
//  Created by windy on 2025/8/24.
//

import UIKit

open class ContainerViewController<Index: ContainerViewIndex>: UIViewController, UIScrollViewDelegate, ContainerViewDelegate {
    
    // MARK: Types
    public typealias Index = Index
    
    // MARK: Struct
    public struct IndexContent {
        
        public let index: Index
        public let content: Content
        
        public init(index: Index, content: Content) {
            self.index = index
            self.content = content
        }
        
        public var frame: CGRect {
            content.view.frame
        }
    }
    
    public struct VisualIndex: Hashable {
        
        public let kind: Kind?
        public let index: Index?
        
        public let isKind: Bool
        
        public init(kind: Kind) {
            self.kind = kind
            self.index = nil
            self.isKind = true
        }
        
        public init(index: Index) {
            self.kind = nil
            self.index = index
            self.isKind = false
        }
        
    }
    
    // MARK: Properties
    open lazy private(set) var container: UIScrollView = {
        let result = UIScrollView(frame: view.bounds)
        result.delegate = self
        result.contentInsetAdjustmentBehavior = .never
        result.isScrollEnabled = false
        result.showsHorizontalScrollIndicator = false
        result.showsVerticalScrollIndicator = false
        return result
    }()
    
    open var contents: [Index: IndexContent] = [:]
    open var selectedContent: IndexContent? = nil
    
    open var selectedIndex: Index? { selectedContent?.index }
    
    private var isSetContentRoot: Bool = false
    
    private var isAddSlideObserver: Bool = false
    private var isPreparedSlideModeContent: Bool = false
    
    open var visualHeaderContent: ContentVisualViewController? = nil
    open var visualFooterContent: ContentVisualViewController? = nil
    
    private var isPreparedVisualContent: Bool = false
    private var shouldVisualResetRect: [Kind: Bool] = .init()
    
    open func childContent<R: Content>() -> R? {
        children.first(where: { ($0 as? R) != nil }) as? R
    }
    
    // MARK: Init
    deinit {
        
        guard isSlideModeOn else { return }
        
        removeSlideModeObserver()
        
    }
    
    // MARK: Life Cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        /// - Tag: Container
        view.addSubview(container)
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard isSetContentRoot == false else { return }
        isSetContentRoot = true
        
        /// - Tag: Selected
        selectedContent(at: containerContentRoot(self))
        
    }
    
    // MARK: Container Append
    private func containerAddSubview(_ view: UIView?) {
        guard let view else { return }
        container.addSubview(view)
    }
    
    private func containerAddVisualView(_ view: UIView?, kind: ContentVisualContentKind) {
        guard let view else { return }
        
        let vc = ContentVisualViewController()
        vc.set(child: view, kind: kind)
        addChild(vc)
        
        switch kind {
        case .header: visualHeaderContent = vc
        case .footer: visualFooterContent = vc
        }
        layoutVisualElements()
        
        container.addSubview(vc.view)
        contentDidMove(vc)
    }
    
    // MARK: Layout
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        container.frame = view.bounds
        
        layoutVisualElements()
        adjustContentSize()
        
    }
    
    fileprivate func adjustContentSize() {
        
        if
            isSlideModeOn,
            let index = Index.self as? any ContainerSlideDiretionIndex.Type
        {
            let count = index.allCases.count
            container.contentSize = .init(
                width: CGFloat(count) * container.frame.width,
                height: container.frame.height
            )
        } else {
            container.contentSize = container.frame.size
        }
        
        if visualHeaderContent != nil {
            container.contentSize.width += visualSize
        }
        
        if visualFooterContent != nil {
            container.contentSize.width += visualSize
        }
        
//        print(#function, #line, container.contentSize)
        
    }
    
    // MARK: Content
    open func containerContentRoot(_ container: ContainerViewController) -> Index {
        fatalError("Methods that must be overridden")
    }
    
    open func container(_ container: ContainerViewController, contentAtIndex index: Index) -> Content {
        fatalError("Methods that must be overridden")
    }
    
    open func container(_ container: ContainerViewController, contentConfiguraionWithContent content: UIViewController, index: Index) {

    }
    
    
    open func container(_ container: ContainerViewController, visualContentByKind kind: Kind) -> VisualContent? {
        nil
    }
    
    open func container(_ container: ContainerViewController, visualChangeProgressWithFactor factor: CGFloat, tendTo: Kind, translation: CGFloat) {
        
    }
    
    open func container(_ container: ContainerViewController, visualDidChangeWithKind kind: Kind) {
        
    }
    
    open func container(_ container: ContainerViewController, visualResetChangeWith isDidChange: Bool, kind: Kind) {
        
    }
    
    // MARK: Selected
    open func selectedContent(at index: Index) {
        prepareSlideModeContent(isOn: isSlideModeOn)
        prepareVisualContent()
        adjustContentSize()
        _selectedContent(at: index)
    }
    
    private func _selectedContent(at index: Index?) {
        guard let index else { return }
        isSlideModeOn
            ? _slideSelectedContent(at: index)
            : _normalSelectedContent(at: index)
//        print(#function, #line, "Selected", container.contentOffset.x)
    }
    
    private func _normalSelectedContent(at index: Index) {
        
        if selectedContent != nil, selectedContent?.index == index {
            return
        }
        
        let content = contents[index]?.content ?? container(self, contentAtIndex: index)
        
        selectedContent?.content.willMove(toParent: nil)
        addChild(content)
        
        container.addSubview(content.view)
        
        content.view.frame = container.bounds
        content.view.frame.origin.x = visualLeadingOffset
        
        contentUpdate(content)
        content.view.alpha = 0
        
        if let selectedContent = selectedContent?.content {
            
            transition(
                from: selectedContent,
                to: content,
                duration: 0.25,
                animations: {
                    selectedContent.view.alpha = 0
                    content.view.alpha = 1
                },
                completion: { isFinished in
                    selectedContent.view.removeFromSuperview()
                    selectedContent.removeFromParent()
                    self.contentDidMove(content)
                    self.container(self, contentConfiguraionWithContent: content, index: index)
                }
            )
            
        } else {
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.25,
                delay: 0,
                animations: {
                    content.view.alpha = 1
                },
                completion: { position in
                    guard position == .end else { return }
                    self.contentDidMove(content)
                    self.container(self, contentConfiguraionWithContent: content, index: index)
                }
            )
            
        }
        
        self.selectedContent = .init(index: index, content: content)
        contents[index] = selectedContent
        
        container.scrollRectToVisible(
            content.view.frame, animated: true
        )
        
    }
    
    private func _slideSelectedContent(at index: Index, isScrollOn: Bool = true) {
        
        if selectedContent != nil, selectedContent?.index == index {
            return
        }
        
        /// 防止重复创建
        if let current = contents[index], isScrollOn {
            container.scrollRectToVisible(
                current.content.view.frame, animated: true
            )
            selectedContent = current
            return
        }
        
        guard
            let slideIndex = index as? (any ContainerSlideDiretionIndex)
        else {
            return
        }
        
        let content = contents[index]?.content ?? container(self, contentAtIndex: index)
        
        selectedContent?.content.willMove(toParent: nil)
        addChild(content)
        
        container.addSubview(content.view)
        content.view.frame = container.bounds

        let indexPath = CGFloat(slideIndex.indexPath)
        let offset = content.view.frame.width
        content.view.frame.origin.x = indexPath * offset + visualLeadingOffset
        
        contentUpdate(content)
        
        if isScrollOn {
            container.scrollRectToVisible(content.view.frame, animated: true)
        }
        
        if selectedContent == nil {
            content.view.alpha = 0
            
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 0.25,
                delay: 0,
                animations: {
                    content.view.alpha = 1
                },
                completion: { position in
                    guard position == .end else { return }
                    self.contentDidMove(content)
                    self.container(self, contentConfiguraionWithContent: content, index: index)
                }
            )
        } else {
            if isScrollOn {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.contentDidMove(content)
                    self.container(self, contentConfiguraionWithContent: content, index: index)
                }
            } else {
                self.contentDidMove(content)
                self.container(self, contentConfiguraionWithContent: content, index: index)
            }
        }
        
        let newSelected = IndexContent(index: index, content: content)
        
        if isScrollOn {
            self.selectedContent = newSelected
        }
        
        contents[index] = newSelected
        
    }
    
    private func contentDidMove(_ content: Content) {
        content.didMove(toParent: self)
        contentUpdate(content)
    }
    
    private func contentUpdate(_ content: Content) {
        content.view.setNeedsUpdateConstraints()
        content.view.setNeedsLayout()
        content.view.setNeedsDisplay()
    }

    private func resetVisibleRect() {
        selectedCurrentContent()
    }
    
    private func selectedCurrentContent() {
        guard let selectedContent else { return }
        container.scrollRectToVisible(
            selectedContent.content.view.frame,
            animated: true
        )
//        print(#function, #line, "Selected", selectedContent.index, selectedContent.content.view.frame)
    }
    
    // MARK: Slide Selected
    public var isSlideModeOn: Bool {
        (Index.self as? any ContainerSlideDiretionIndex.Type) != nil &&
        containerShouldSlideModeOn(self)
    }
    
    open func prepareSlideModeContent(isOn: Bool) {
        
        guard isPreparedSlideModeContent == false else { return }
        isPreparedSlideModeContent = true
        
        container.isScrollEnabled = isOn
        container.isPagingEnabled = isOn
        container.alwaysBounceHorizontal = isOn
        container.alwaysBounceVertical = false
        
        layoutVisualElements()
        adjustContentSize()
        
        if isOn {
            addSlideModeObserver()
        } else {
            removeSlideModeObserver()
        }
        
    }
    
    private func addSlideModeObserver() {
        container.panGestureRecognizer.addObserver(
            self,
            forKeyPath: #keyPath(UIPanGestureRecognizer.state),
            options: [.old, .new],
            context: nil
        )
        isAddSlideObserver = true
    }
    
    private func removeSlideModeObserver() {
        guard isAddSlideObserver else { return }
        container.panGestureRecognizer.removeObserver(
            self,
            forKeyPath: #keyPath(UIPanGestureRecognizer.state)
        )
    }
    
    open func containerShouldSlideModeOn(_ container: ContainerViewController) -> Bool {
        false
    }
    
    open func container(_ container: ContainerViewController, slideProgressWithFactor factor: CGFloat, tendTo: Index, translation: CGFloat) {
        
    }
    
    open func container(_ container: ContainerViewController, slideDidChangeWithOld old: Index, new: Index) {
        
    }
    
    // MARK: Visual Content
    private func prepareVisualContent() {
        
        guard isPreparedVisualContent == false else { return }
        isPreparedVisualContent = true
        
        /// - Tag: Visual Content
        let header = container(self, visualContentByKind: .header)
        let footer = container(self, visualContentByKind: .footer)
        
        containerAddVisualView(header, kind: .header)
        containerAddVisualView(footer, kind: .footer)
        
        if isSlideModeOn == false {
            container.isScrollEnabled = header != nil || footer != nil
            container.isPagingEnabled = container.isScrollEnabled
            container.alwaysBounceHorizontal = container.isScrollEnabled
            container.alwaysBounceVertical = false
        }
        
    }
    
    private func layoutVisualElements() {
        
        visualHeaderContent?.view.frame = view.bounds
        visualFooterContent?.view.frame = view.bounds
        
        if let header = visualHeaderContent {
            header.view.frame.origin.x = 0
            header.view.frame.size.width = visualSize
        }
        
        if let footer = visualFooterContent {
            if
                isSlideModeOn,
                let index = Index.self as? any ContainerSlideDiretionIndex.Type
            {
                let count = index.allCases.count
                footer.view.frame.origin.x = CGFloat(count) * container.frame.width
            } else {
                footer.view.frame.origin.x = container.frame.width
            }
            footer.view.frame.origin.x += (visualHeaderContent?.view.frame.width ?? .zero)
            footer.view.frame.size.width = visualSize
        }
        
    }
    
    private func resetVisualVisibleRect() {
        guard shouldResetVisualVisibleRect else {
            return
        }
        selectedCurrentContent()
    }
    
    private var shouldResetVisualVisibleRect: Bool {
        guard isPreparedVisualContent else { return false }
        var result: Bool = false
        if visualHeaderContent != nil {
            result = result || shouldVisualResetRect[.header] ?? false
        }
        if visualFooterContent != nil {
            result = result || shouldVisualResetRect[.footer] ?? false
        }
        return result
    }
    
    private var visualSize: CGFloat {
        container.frame.width // * 0.5
    }
    
    private var visualLeadingOffset: CGFloat {
        visualHeaderContent == nil ? 0 : visualSize
    }
    
    // MARK: UIScrollViewDelegate
    private var beganScrollOffset: CGFloat = .zero
    private var canChange: Bool = false
    private var isDragEnded: Bool = false
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        isSlideModeOn
            ? slideScrollViewDidScroll(scrollView)
            : normalScrollViewDidScroll(scrollView)
        
//        print(#function, #line, "Selected", scrollView.contentOffset.x, scrollView.contentSize.width, (container.contentSize.width - container.frame.width - visualSize))
        
    }
    
    open func normalScrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard
            canChange,
            selectedContent?.index != nil
        else {
            return
        }
        
        let page = scrollView.frame.width
        let halfPage = page * 0.5
        let scrollOffset = scrollView.contentOffset.x
        
        let scrollOffsetDelta = scrollOffset - beganScrollOffset
        
        let tendToKind: ContentVisualContentKind?
        if scrollOffsetDelta < 0 {
            tendToKind = .header
        }
        else if scrollOffsetDelta > 0 {
            tendToKind = .footer
        }
        else {
            tendToKind = nil
        }
        
        let factor = scrollOffsetDelta / halfPage
        
        func clampFactor(_ v: CGFloat) -> CGFloat {
            if v < -1 { return -1 }
            else if v > 1 { return 1 }
            else { return v }
        }
        
        guard let tendToKind else {
            return
        }
        
        if isDragEnded == false {
            container(
                self,
                visualChangeProgressWithFactor: clampFactor(factor),
                tendTo: tendToKind,
                translation: touchTranslation().x
            )
        }
        
//        print(#function, scrollOffset, currentIndex, tendToKind, scrollOffsetDelta)
        
        if isDragEnded {
            self.container(self, visualResetChangeWith: false, kind: tendToKind)
        }
        
        guard isDragEnded, abs(scrollOffsetDelta) > halfPage else {
            return
        }
        
        canChange = false
        
        shouldVisualResetRect[tendToKind] = true
        
//        print(#function, "Change", currentIndex, tendToKind)
        
        container(self, visualDidChangeWithKind: tendToKind)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.resetVisibleRect()
            self.container(self, visualResetChangeWith: true, kind: tendToKind)
//        }
        
    }
    
    open func slideScrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard
            canChange,
            let currentIndex = selectedContent?.index as? (any ContainerSlideDiretionIndex)
        else {
            return
        }
        
        let isFirstIndex = currentIndex.isEqualToFirst()
        let isLastIndex = currentIndex.isEqualToLast()
        
//        print(#function, #line, isFirstIndex, isLastIndex)
        
        let page = scrollView.frame.width
        let halfPage = page * 0.5
        let scrollOffset = scrollView.contentOffset.x
        
        let scrollOffsetDelta = scrollOffset - beganScrollOffset
        
        let tendToSelectedIndex: (any ContainerSlideDiretionIndex)?
        let tendToKind: ContentVisualContentKind?
        
        if scrollOffsetDelta < 0 {
            tendToKind = isFirstIndex ? .header : nil
            tendToSelectedIndex = tendToKind == nil ? currentIndex.preview : nil
        }
        else if scrollOffsetDelta > 0 {
            tendToKind = isLastIndex ? .footer : nil
            tendToSelectedIndex = tendToKind == nil ? currentIndex.next : nil
        }
        else {
            tendToSelectedIndex = nil
            tendToKind = nil
        }
        
        let factor = scrollOffsetDelta / halfPage
        
        func clampFactor(_ v: CGFloat) -> CGFloat {
            if v < -1 { return -1 }
            else if v > 1 { return 1 }
            else { return v }
        }
        
        let shouldChange = abs(scrollOffsetDelta) > halfPage
        
        if let tendToKind {
            
            if isDragEnded == false {
                container(
                    self,
                    visualChangeProgressWithFactor: clampFactor(factor),
                    tendTo: tendToKind,
                    translation: touchTranslation().x
                )
            }
            
            if isDragEnded {
                self.container(self, visualResetChangeWith: false, kind: tendToKind)
            }
            
            guard isDragEnded, shouldChange else {
                return
            }
            
            canChange = false
            shouldVisualResetRect[tendToKind] = true
            container(self, visualDidChangeWithKind: tendToKind)
            
            self.resetVisibleRect()
            self.container(self, visualResetChangeWith: true, kind: tendToKind)
        }
        
        if let tendToSelectedIndex {
            
            container(
                self,
                slideProgressWithFactor: clampFactor(factor),
                tendTo: tendToSelectedIndex as! Index,
                translation: touchTranslation().x
            )
            
            //        print(#function, scrollOffset, currentIndex, tendToSelectedIndex, scrollOffsetDelta)
            
            _slideSelectedContent(at: tendToSelectedIndex as! Index, isScrollOn: false)
            
            guard isDragEnded, shouldChange else {
                return
            }
            
            //        print(#function, "Change", currentIndex, tendToSelectedIndex)
            
            canChange = false
            
            selectedContent = contents[tendToSelectedIndex as! Index]
            
            selectedCurrentContent()
            container(
                self,
                slideDidChangeWithOld: currentIndex as! Index,
                new: tendToSelectedIndex as! Index
            )
            
        }
        
    }
    
    // MARK: Observer
    private var touchBeganLocation: CGPoint = .zero
    private var touchCurrentLocation: CGPoint = .zero
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        let state = container.panGestureRecognizer.state
        
        if state == .began {
            canChange = true
            isDragEnded = false
            shouldVisualResetRect = .init()
            beganScrollOffset = container.contentOffset.x
            touchBeganLocation = container.panGestureRecognizer.location(in: view)
            touchCurrentLocation = .zero
//            print(#function, beganScrollOffset)
        }
        
        if state == .ended || state == .cancelled || state == .failed {
            isDragEnded = true
//            print(#function, beganScrollOffset)
        }
        
    }
    
    private func touchTranslation() -> CGPoint {
        touchCurrentLocation = container.panGestureRecognizer.location(in: view)
        return .init(
            x: abs(touchCurrentLocation.x - touchBeganLocation.x),
            y: abs(touchCurrentLocation.y - touchBeganLocation.y)
        )
    }
    
}

extension ContainerViewController where Index: ContainerSlideDiretionIndex {
    
    // MARK: Progress Selected
    open func selectedProgress(factor: CGFloat, tendTo: Index) {
        guard
            isSlideModeOn,
            let current = selectedContent
        else {
            return
        }
        
        let halfPage = current.frame.width // * 0.5
        
        let isPreview = current.index.preview == tendTo
        let isNext = current.index.next == tendTo
        
        let translation: CGFloat
        
        if isPreview {
            translation = -halfPage * factor
        }
        else if isNext {
            translation = halfPage * factor
        }
        else {
            translation = .zero
        }
        
        let offset = CGPoint(x: translation, y: 0)
        container.setContentOffset(offset, animated: false)
        
    }

    
}
