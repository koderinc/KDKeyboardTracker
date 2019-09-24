# KDKeyboardTracker

![](https://img.shields.io/badge/Swift-5.1-Orange) ![](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen) [![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg)](https://opensource.org/licenses/MIT)

By default, iOS allows you to monitor changes to the keyboard via NSNotifications. However, once you need to stick a view to the top of the keyboard and support interative dismiss, things get more involved. 

This package is heavily inspired by [this article](https://medium.com/ios-os-x-development/a-stickler-for-details-implementing-sticky-input-fields-in-ios-f88553d36dab) and the resulting [Objective-C repo](https://github.com/meiwin/NgKeyboardTracker).


![](Docs/Assets/Demo.gif)

---

### Usage

#### Observering Standard Keyboard changes

A common use case of the keyboard tracker is monitoring keyboard state changes in your view controller.

A good method for this would be in the view controller's `willMove(toParent:)` method. 

```
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

```
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
#### Observering Interactive Dismissal

KeyboardTracker uses `PseudoInputAccessoryViewCoordinator` to track interactive keyboard dismissal. 

To enable tracking, you must override the `loadView()` of your controller and set the view to a custom view.

Override `loadView()` in your controller:
```
override func loadView() {
    let view = CustomView(frame: UIScreen.main.bounds)
    view.becomeFirstResponder()
    self.view = view
}
```

Example custom `UIView`:
```
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
        fatalError("init(coder:) has not been implemented")
    }
    
}
```


Check out the sample app in this repo to try out the features above.

---

### Installing the package

##### Add KDKeyboardTracker to your Package.swift file

```
.package(url: /* package url */, from: "1.0.0"),
```

Be sure to expose `KDKeyboardTracker` as a dependency in the targets as well.

```
import KDKeyboardTracker
```

where you plan to use it.

If you are new to Swift Package Manager, here's how you can set up your project:

To take advantage of the modularity that SPM provides, we suggest creating your project in a workspace, and adding your packages there. 

Once you create your workspace, add your Xcode project to it. 

##### Adding a `Package.swift` file to your workspace:

1. Open your workspace
2. Using the `+` button in the bottom left, select `New Swift Package`
3. Give it a name like `PackageLibrary` and make sure 'Create Git Repository on my Mac' is unselected as the package will be part of your project's source control

##### Embedding the Swift Package in your project

1. Open your app’s project settings, select your app target, and navigate to its General pane.
2. Click the `+` button in the “Frameworks, Libraries, and Embedded Content” section and select the package’s library to link it into your app target.

##### Adding 3rd Party Packages

1. Open the Package.swift file
2. Add dependencies in the array:

```
dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
```

Open the Xcode workspace in the Example project to see how we've set things up.

---

## License

KDKeyboardTracker is released under the MIT license. See ![LICENSE](LICENSE) for details.

