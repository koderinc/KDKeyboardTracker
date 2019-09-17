//
//  ViewController.swift
//  KDKeyboardTracker-Example
//
//  Created by Aaron Satterfield on 9/17/19.
//  Copyright © 2019 Koder, Inc. All rights reserved.
//

import UIKit
import KDKeyboardTracker

class ViewController: UIViewController, KeyboardTrackerDelegate {
    
    var didSetConstraints = false
    
    lazy var stateLabel: UILabel = {
        let l = UILabel()
        l.text = "Current State: \(KeyboardTracker.shared.appearanceState)"
        return l
    }()
    
    lazy var frameLabel: UILabel = {
        let l = UILabel()
        l.text = "Frame: \(KeyboardTracker.shared.currentFrame)"
        return l
    }()
    
    lazy var textField: UITextField = {
        let t = UITextField()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.widthAnchor.constraint(equalToConstant: 200).isActive = true
        t.borderStyle = .roundedRect
        return t
    }()
    
    lazy var stackView: UIStackView = {
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
    }()
    
    lazy var scrollView: UIScrollView = {
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
    }()
    
    override func loadView() {
        // to enable interactive dismiss observing
        let view = CustomView(frame: UIScreen.main.bounds)
        view.becomeFirstResponder()
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        view.setNeedsUpdateConstraints()
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
        if parent != nil {
            KeyboardTracker.shared.addObserver(keyboardObserver: self)
        } else {
            KeyboardTracker.shared.removeObserver(keyboardObserver: self)
        }
    }
    
    func keyboardTrackerDidUpdate(tracker: KeyboardTracker) {
        frameLabel.text = "Frame: \(KeyboardTracker.shared.currentFrame)"
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

}

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
