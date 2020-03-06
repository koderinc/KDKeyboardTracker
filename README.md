# KDKeyboardTracker

![](https://img.shields.io/badge/Swift-5.1-Orange) ![](https://img.shields.io/badge/SPM-compatible-brightgreen) [![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

By default, iOS allows you to monitor changes to the keyboard via NSNotifications. However, once you need to stick a view to the top of the keyboard and support interative dismiss, things get more involved. 

This package is heavily inspired by [this article](https://medium.com/ios-os-x-development/a-stickler-for-details-implementing-sticky-input-fields-in-ios-f88553d36dab) and the resulting [Objective-C repo](https://github.com/meiwin/NgKeyboardTracker).


![](Docs/Assets/Demo.gif)

---

### Usage

#### Observering Standard Keyboard changes

A common use case of the keyboard tracker is monitoring keyboard state changes in your view controller.

A good method for this would be in the view controller's `willMove(toParent:)` method. 

```swift
override func willMove(toParent parent: UIViewController?) {
    super.willMove(toParent: parent)
    if parent != nil {
        KeyboardTracker.shared.addObserver(keyboardObserver: self)
    } else {
        KeyboardTracker.shared.removeObserver(keyboardObserver: self)
    }
}
```
Adding your controller to the Keyboard tracker's observers, will automatically begin generating updates for keyboard changes. When all observers are removed from the tracker, the tracker stops observing changes.

```swift
func keyboardTrackerDidUpdate(tracker: KeyboardTracker) {
    // observe frame changes 
}
    
func keyboardTrackerDidChangeAppearanceState(tracker: KeyboardTracker) {
    switch tracker.appearanceState {
    case .undefined:
        break
    case .willShow:
        break
    case .willHide:
        break
    case .shown:
        break
    case .hidden:
        break
    }
}
```
#### Observing Interactive Dismissal

KeyboardTracker uses `PseudoInputAccessoryViewCoordinator` to track interactive keyboard dismissal. 

To enable tracking, you must override the `loadView()` of your controller and set the view to a custom view.

Override `loadView()` in your controller:
```swift
override func loadView() {
    let view = CustomView(frame: UIScreen.main.bounds)
    view.becomeFirstResponder()
    self.view = view
}
```

Example custom `UIView`:
```swift
class CustomView: UIView {
    
    var inputCoordinator: PseudoInputAccessoryViewCoordinator!
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return inputCoordinator.pseudoInputAccessoryView
    }
    
    override init(frame: CGRect) {
        inputCoordinator = KeyboardTracker.shared.createCoordinator()
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
    
}
```


Check out the sample app in this repo to try out the features above.

---

### Installation

Xcode makes it easy to add Swift Packages to your project. 

Ensure your target is selected and navigate to the General tab of your application's bundle.

In the Frameworks, Libraries, and Embedded Content section, click the '+' button to add a new dependency. 

Select the "Add Other..." dropdown and choose "Add Package Dependency" enter the package url:
https://github.com/koderinc/KDKeyboardTracker.git

Continue through the wizard until the package is added.

From here, simply `import KDKeyboardTracker` where needed.

For information about adding a Swift Package Dependency to your project, [see Apple's documentation here](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

---

## License

KDKeyboardTracker is released under the MIT license. See [LICENSE](LICENSE) for details.

