//
//  PseudoInputAccessoryViewCoordinator.swift
//  
//
//  Created by Aaron Satterfield on 8/23/19.
//

import Foundation
import UIKit

protocol PseudoInputAccessoryViewDelegate: class {
    func pseudoInputAccessoryView(_ : PseudoInputAccessoryView, didChangeKeyboardFrame frame: CGRect)
}

// MARK: -

open class PseudoInputAccessoryView: UIView {
    
    var height: CGFloat? {
        didSet {
            guard let height = height else {
                return
            }
            heightConstraint?.constant = height
        }
    }
    
    private(set) var heightConstraint: NSLayoutConstraint?
    
    weak var delegate: PseudoInputAccessoryViewDelegate?
    
    private var observation: NSKeyValueObservation?
    
    private let selectorForSuperview = "center"
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        stopObserving()
        observation = newSuperview?.observe(\.center, changeHandler: { [weak self] (view, change) in
            let kbFrame = view.convert(view.bounds, to: nil)
            self?.keyboardFrameDidChange(frame: kbFrame)
        })
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        heightConstraint = constraints.first(where: {
            $0.firstItem as? PseudoInputAccessoryView == self &&
            $0.firstAttribute == .height &&
            $0.relation == .equal
        })
        height = heightConstraint?.constant
    }
    
    deinit {
        stopObserving()
    }
    
    func stopObserving() {
        observation?.invalidate()
    }
    
    func keyboardFrameDidChange(frame newFrame: CGRect) {
        delegate?.pseudoInputAccessoryView(self, didChangeKeyboardFrame: newFrame)
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
}

// MARK: -

protocol PseudoInputAccessoryViewCoordinatorDelegate: class {
    func keyboardFrameDidChange(frame: CGRect)
}

// MARK: -

open class PseudoInputAccessoryViewCoordinator: NSObject, PseudoInputAccessoryViewDelegate {
    
    // MARK: Properties
    public lazy var pseudoInputAccessoryView: PseudoInputAccessoryView = {
        let v = PseudoInputAccessoryView()
        v.backgroundColor = .clear
        v.delegate = self
        v.isUserInteractionEnabled = true
        return v
    }()

    public var pseudoInputAccessoryViewHeight: CGFloat {
        get {
            return pseudoInputAccessoryView.height ?? .zero
        } set {
            pseudoInputAccessoryView.height = newValue
        }
    }
    
    weak var delegate: PseudoInputAccessoryViewCoordinatorDelegate?
    
    var isActive: Bool {
        return pseudoInputAccessoryView.superview != nil
    }

    func keyboardFrameDidChange(newFrame: CGRect) {
        delegate?.keyboardFrameDidChange(frame: newFrame)
    }
    
    // MARK: PseudoInputAccessoryViewDelegate
    
    func pseudoInputAccessoryView(_: PseudoInputAccessoryView, didChangeKeyboardFrame frame: CGRect) {
        keyboardFrameDidChange(newFrame: frame)
    }
    
}
