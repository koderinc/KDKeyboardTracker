//
//  KDKeyboardTracker.swift
//  KDKeyboardTracker
//
//  Created by Aaron Satterfield on 8/23/19.
//  Copyright (c) 2019 Koder, Inc. All rights reserved.
//

import Foundation
import UIKit

public enum KeyboardAppearanceState: String {
    case undefined, willShow, willHide, shown, hidden
}

// MARK: -

public typealias KeyboardObserver = KeyboardTrackerDelegate & NSObject

public protocol KeyboardTrackerDelegate: class {
    
    /// Called when the state of the keyboard tracker changes
    func keyboardTrackerDidUpdate(tracker: KeyboardTracker)
    
    /// Called when on keyboard notifications
    func keyboardTrackerDidChangeAppearanceState(tracker: KeyboardTracker)
    
}

// MARK: -

open class KeyboardTracker: NSObject, PseudoInputAccessoryViewCoordinatorDelegate {
    
    // MARK: Properties
    
    open private(set) var appearanceState: KeyboardAppearanceState = .undefined
    
    // Frames
    
    open private(set) var beginFrame: CGRect = .zero
    open private(set) var endFrame: CGRect = .zero
    open private(set) var currentFrame: CGRect = .zero
    open private(set) var windowSize: CGSize = .zero

    // Animation
    open private(set) var animationDuration: TimeInterval = .zero
    open private(set) var animationCurve: UIView.AnimationCurve = .easeOut
    open private(set) var animationOptions: UIView.AnimationOptions = []
    
    // Internal properties
    private var observers: [KeyboardObserver] = [] {
        didSet {
            isTracking = !observers.isEmpty
        }
    }
    
    private var inputAccessoryViewHeight: CGFloat = .zero
    
    /// Keyboard is being tracked. Do not set this property directly. It will be set depending on the trackers observers.
    private(set) var isTracking: Bool = false {
        didSet {
            guard oldValue != isTracking else {
                return
            }
            if isTracking {
                start()
            } else {
                stop()
            }
        }
    }

    // MARK: Shared Instance
    
    /// Shared keyboard tracker singleton
    public static var shared: KeyboardTracker = KeyboardTracker()
    
    override init() {
        super.init()
    }
    
    // MARK: Start/Stop Tracking
    
    /// Begin keyboard tracking.
    private func start() {
        let notifications: [(Notification.Name, Selector)] = [
            (UIResponder.keyboardWillShowNotification, #selector(self.keyboardWillShow(notification:))),
            (UIResponder.keyboardWillHideNotification, #selector(self.keyboardWillHide(notification:))),
            (UIResponder.keyboardDidShowNotification, #selector(self.keyboardDidShow(notification:))),
            (UIResponder.keyboardDidHideNotification, #selector(self.keyboardDidHide(notification:))),
            (UIResponder.keyboardWillChangeFrameNotification, #selector(self.keyboardFrameWillChange(notification:))),
            (UIResponder.keyboardDidChangeFrameNotification, #selector(self.keyboardFrameDidChange(notification:)))
        ]
        notifications.forEach {
            NotificationCenter.default.addObserver(self, selector: $0.1, name: $0.0, object: nil)
        }
        getInitialKeyboardInfo()
    }
    
    /// End keyboard tracking.
    private func stop() {
        NotificationCenter.default.removeObserver(self)
        isTracking = false
    }
    
    private func getKeyboardView() -> UIView? {
        let windows = UIApplication.shared.windows
        guard windows.count > 1 else {
            return nil
        }
        let testWindow = windows[1]
        windowSize = testWindow.bounds.size
        for subview in testWindow.subviews {
            if subview.description.contains(TestWindowKeys.peripheralHostKey) {
                return subview
            } else if subview.description.contains(TestWindowKeys.inputSetContainerView) {
                for subview in subview.subviews {
                    guard subview.description.contains(TestWindowKeys.inputSetHost) else {
                        continue
                    }
                    return subview
                }
            }
        }
        return nil
    }

    private func getInitialKeyboardInfo() {
        if let keyboardView = getKeyboardView() {
            appearanceState = .shown
            beginFrame = keyboardView.convert(keyboardView.bounds, to: nil)
            endFrame = beginFrame
        } else {
            appearanceState = .hidden
            beginFrame = .zero
            endFrame = .zero
            animationCurve = .easeOut
            animationDuration = .zero
        }
        updateObservers()
    }
    
    private func updateObservers() {
        observers.forEach {
            $0.keyboardTrackerDidUpdate(tracker: self)
        }
    }
    
    private func updateAppearance() {
        observers.forEach {
            $0.keyboardTrackerDidChangeAppearanceState(tracker: self)
        }
    }
    
    // MARK: Internal Helpers
    
    // Type-safe keys for testing keyboard window location
    private struct TestWindowKeys {
        static let peripheralHostKey = "<UIPeripheralHost"
        static let inputSetContainerView = "<UIInputSetContainerView"
        static let inputSetHost = "<UIInputSetHost"
    }
    
    
    // MARK: Keyboard Notification Updates
    
    @objc func keyboardWillShow(notification: Notification) {
        updateAppearanceState(.willShow)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        updateAppearanceState(.willHide)
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        // when we use the interactive input accessory, a shown notification gets fired after it hide
        // check to make sure the keyboard is actually visable before setting it as shown
        updateAppearanceState(isKeyboardVisible ? .shown : .hidden)
    }
    
    @objc func keyboardDidHide(notification: Notification) {
        updateAppearanceState(.hidden)
    }
    
    @objc func keyboardFrameWillChange(notification: Notification) {
        self.captureInfo(notification.userInfo)
        updateObservers()
    }
    
    @objc func keyboardFrameDidChange(notification: Notification) {
        self.captureInfo(notification.userInfo)
        updateObservers()
    }
    
    // MARK: Tracking Responders
    private func updateAppearanceState(_ newState: KeyboardAppearanceState) {
        appearanceState = newState
        updateAppearance()
    }
    
    // MARK: Events
    private func captureInfo(_ info: [AnyHashable: Any]?) {
        beginFrame = (info?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? beginFrame
        endFrame = (info?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? endFrame
        currentFrame = endFrame
        animationDuration = (info?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? animationDuration
        if let value = (info?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) {
            animationCurve = UIView.AnimationCurve(rawValue: value) ?? animationCurve
        }
    }
    
    // MARK: PseudoInputAccessoryViewCoordinatorDelegate
    
    func keyboardFrameDidChange(frame: CGRect) {
        guard isTracking else {
            return
        }
        currentFrame = frame
        animationDuration = 0
        updateObservers()
    }
    
}

// MARK: - Public Access
extension KeyboardTracker {
    
    // MARK: Add/Remove Observers
    
    /// Add a keyboard observer that subscribes to keyboard changes and events
    open func addObserver(keyboardObserver: KeyboardObserver) {
        removeObserver(keyboardObserver: keyboardObserver)
        observers.append(keyboardObserver)
    }
    
    /// Remove your keyboard observer when tracking is not longer needed
    open func removeObserver(keyboardObserver: KeyboardObserver) {
        observers.removeAll(where: {$0 == keyboardObserver})
    }
    
    /// Creates a `PseudoInputAccessoryViewCoordinator` for intractive keyboard tracking
    open func createCoordinator() -> PseudoInputAccessoryViewCoordinator {
        let coordinator = PseudoInputAccessoryViewCoordinator()
        coordinator.delegate = self
        return coordinator
    }
    
    // MARK: Convenience Methods
    
    /// Returns whether the keyboard is currently visible on screen
    /// Calculated using `currentFrame` state
    public final var isKeyboardVisible: Bool {
        guard appearanceState != .hidden else {
            return false
        }
        let intersection = UIScreen.main.bounds.intersection(currentFrame)
        return intersection.size.height - inputAccessoryViewHeight > 0
    }
    
}
