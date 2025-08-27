# SpaceRoom

Is a controller container。

# Installation

```swift
dependencies: [
    .package(url: "https://github.com/huangwenfei/SpaceRoom.git", .upToNextMajor(from: "0.0.1"))
]
```

```swift
import SpaceRoom
```

# Usage

## Pay Attention

<img width="606" height="154" alt="Segment" src="https://github.com/user-attachments/assets/c1eb0c18-7efe-47cb-9818-48f078c326e4" />

This is a capability of the [ScrollableSegment](https://github.com/huangwenfei/ScrollableSegment) library and is not included in `SpaceRoom`.

## Tap

![Tap](https://github.com/user-attachments/assets/7c060866-9d5d-4e92-816f-3dc906f57c53)

```swift

enum Index: Int, CaseIterable, ContainerViewIndex {
    case yellow, red, purple
}

class ViewController: ContainerViewController<Index> {

  /// some code ....

  /// button action Or other
  func tapAction(index: Index) {
    /// When index changes, you need to actively select a new controller
    selectedContent(at: index)
  }

  /// This method 'containerContentRoot' is called once when the 'ViewController' is about to appear
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

}

```

## Slide

![Slide](https://github.com/user-attachments/assets/b1a3c445-8374-4bec-8d9e-1480a47a49c2)

```swift

enum Index: Int, CaseIterable, ContainerSlideDiretionIndex {
    case yellow, red, purple
}

class ViewController: ContainerViewController<Index> {

  /// some code ....

  /// button action Or other
  func tapAction(index: Index) {
    /// When index changes, you need to actively select a new controller
    selectedContent(at: index)
  }

  override func containerShouldSlideModeOn(_ container: ContainerViewController<Index>) -> Bool {
    /// if `true`, slide mode, if `false`, normal tap mode
    true
  }
  
  override func container(_ container: ContainerViewController<Index>, slideProgressWithFactor factor: CGFloat, tendTo: Index, translation: CGFloat) {
    /// Listen for the scrolling progress and the index you are going to
  }
  
  override func container(_ container: ContainerViewController<Index>, slideDidChangeWithOld old: Index, new: Index) {
    /// A method that is called when the scroll distance is met and the content is changed
  }

}

```
