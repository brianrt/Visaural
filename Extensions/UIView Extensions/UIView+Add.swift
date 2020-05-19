//
//  UIView+Add.swift
//  Swift Synth
//
//  Created by Brian Thompson.
//

import UIKit

extension UIView {
    public func add(_ subviews: UIView...) {
        subviews.forEach(addSubview)
    }
}
