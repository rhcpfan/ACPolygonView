//
//  MagnifierView.swift
//  PolygonView
//
//  Created by Andrei Ciobanu on 03/11/2019.
//  Copyright © 2019 Andrei Ciobanu. All rights reserved.
//

import UIKit

enum MagnifierViewShape {
    case round, square
}

public class MagnifierView: UIView {

    // MARK: - Instance Properties -

    var magnifiedView: UIView! { didSet { self.updateMagnifiedView() }}
    var touchCenterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 4, height: 4)))
    
    var scaleFactor:CGFloat = 2.0 {
        didSet { self.setNeedsDisplay() }
    }

    var shape: MagnifierViewShape = .square {
        willSet {
            UIView.animate(withDuration: 0.25, animations: {
                self.layer.masksToBounds = (newValue == .round)
                self.layer.cornerRadius = (newValue == .round) ? min(self.frame.width, self.frame.height) / 2.0 : 0.0
            }, completion: { (_) in
                if newValue == .square {
                    self.layer.masksToBounds = false
                }
            })
        }
    }

    var touchLocation: CGPoint? {
        didSet { self.setNeedsDisplay() }
    }

    // MARK: - Drawing -

    func updateMagnifiedView() {
        let hasCenterView = self.magnifiedView?.subviews.contains(touchCenterView) ?? false
        if !hasCenterView {
            self.touchCenterView.isHidden = true
            self.touchCenterView.backgroundColor = .red
            self.touchCenterView.clipsToBounds = true
            self.touchCenterView.layer.cornerRadius = self.touchCenterView.frame.height / 2.0
            self.magnifiedView?.addSubview(touchCenterView)
        }
    }

    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        if let location = self.touchLocation {
            var dx = -1 * (location.x + self.frame.width / self.scaleFactor / 2.0)
            var dy = -1 * (location.y + self.frame.height / self.scaleFactor / 2.0)

            if location.x <= self.frame.width / self.scaleFactor / 2.0 {
                dx = -1 * self.frame.width / self.scaleFactor
            } else if location.x >= self.magnifiedView.frame.width - self.frame.width / self.scaleFactor / 2.0 {
                dx = -1 * self.magnifiedView.frame.width
            }

            if location.y <= self.frame.height / self.scaleFactor / 2.0 {
                dy = -1 * self.frame.height / self.scaleFactor
            } else if location.y >= self.magnifiedView.frame.height - self.frame.height / self.scaleFactor / 2.0 {
                dy = -1 * self.magnifiedView.frame.height
            }
            
            self.isHidden = true
            if let context = UIGraphicsGetCurrentContext() {
                context.translateBy(x: self.frame.width, y: self.frame.height)
                context.scaleBy(x: self.scaleFactor, y: self.scaleFactor)
                context.translateBy(x: dx, y: dy)
                self.magnifiedView.layer.render(in: context)
            }
            self.isHidden = false
        }
    }
}
