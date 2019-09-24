//
//  ViewController.swift
//  KDKeyboardTracker-Example
//
//  Created by Aaron Satterfield on 9/17/19.
//  Copyright © 2019 Koder, Inc. All rights reserved.
//

import UIKit
import KDKeyboardTracker

/// Custom view to support interactive dismiss observing
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

// MARK: -
class ViewController: UIViewController, KeyboardTrackerDelegate {
    
    var didSetConstraints = false
    
    // MARK: Subviews
    
    lazy var stateLabel = createStateLabel()
    lazy var frameLabel = createFrameLabel()
    lazy var textField = createTextField()
    lazy var stackView = createStackView()
    lazy var scrollView = createScrollView()
    
    // MARK: Setup
    
    override func loadView() {
        // To enable interactive dismiss observing
        // Comment out this function if you do not need to support interactive dismissal
        let view = CustomView(frame: UIScreen.main.bounds)
        view.becomeFirstResponder()
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "KDKeyboardTracker"
        view.addSubview(scrollView)
        view.setNeedsUpdateConstraints()
        keyboardTrackerDidUpdate(tracker: KeyboardTracker.shared)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actionDismissKeyboard)))
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        guard !didSetConstraints else {
            return
        }
        didSetConstraints = true
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        scrollView.subviews.first?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.subviews.first?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.subviews.first?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.subviews.first?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        // Add/Remove keyboard observer if view is being shown or dismissed
        if parent != nil {
            // view is being shown
            KeyboardTracker.shared.addObserver(keyboardObserver: self)
        } else {
            // view was dismissed
            KeyboardTracker.shared.removeObserver(keyboardObserver: self)
        }
    }
    
    // MARK: KeyboardTrackerDelegate
    
    func keyboardTrackerDidUpdate(tracker: KeyboardTracker) {
        let f = tracker.currentFrame
        let frameText = String(format: "x: %.0f, y: %.0f, w: %.0f, h: %.0f", f.minX, f.minY, f.width, f.height)
        frameLabel.text = frameText
    }
       
    func keyboardTrackerDidChangeAppearanceState(tracker: KeyboardTracker) {
        var stateText = "Current State: "
        switch tracker.appearanceState {
        case .undefined:
            stateText.append("undefined")
            break
        case .willShow:
            stateText.append("willShow")
            break
        case .willHide:
            stateText.append("willHide")
            break
        case .shown:
            stateText.append("shown")
            break
        case .hidden:
            stateText.append("hidden")
            break
        }
        stateLabel.text = stateText
    }
    
    // MARK: Actions
    
    @objc func actionDismissKeyboard() {
        textField.resignFirstResponder()
    }


}

// MARK: - Create subview helpers
extension ViewController {
    
    func createStateLabel() -> UILabel {
        let l = UILabel()
        l.text = "Current State: \(KeyboardTracker.shared.appearanceState)"
        return l
    }
    
    func createFrameLabel() -> UILabel {
        let l = UILabel()
        l.text = "Frame: - - - -"
        return l
    }
    
    func createTextField() -> UITextField {
        let t = UITextField()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.widthAnchor.constraint(equalToConstant: 200).isActive = true
        t.borderStyle = .roundedRect
        return t
    }
    
    func createStackView() -> UIStackView {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.distribution = .fillEqually
        s.alignment = .center
        s.addArrangedSubview(stateLabel)
        s.addArrangedSubview(frameLabel)
        s.addArrangedSubview(textField)
        s.setContentHuggingPriority(.required, for: .vertical)
        return s
    }
    
    func createScrollView() -> UIScrollView {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.keyboardDismissMode = .interactive
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        s.addSubview(v)
        v.addSubview(stackView)
        v.topAnchor.constraint(equalTo: s.topAnchor).isActive = true
        v.bottomAnchor.constraint(equalTo: s.bottomAnchor).isActive = true
        v.leadingAnchor.constraint(equalTo: s.leadingAnchor).isActive = true
        v.trailingAnchor.constraint(equalTo: s.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: v.centerYAnchor, constant: -100.0).isActive = true
        stackView.centerXAnchor.constraint(equalTo: v.centerXAnchor).isActive = true
        return s
    }
}
