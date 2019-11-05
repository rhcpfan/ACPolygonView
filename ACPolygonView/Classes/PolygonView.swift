//
//  PolygonView.swift
//  PolygonView
//
//  Created by Andrei Ciobanu on 03/11/2019.
//  Copyright © 2019 Andrei Ciobanu. All rights reserved.
//

import UIKit

public class PolygonView: UIView {

    // MARK: - Instance Properties -

    /// A magnifier view used to display a more precise location of the polygon points.
    public var magnifiedView: UIView? { didSet { self.updateMagnifiedView() }}
    /// A magnifier view used to display a more precise location of the polygon points.
    private var magnifierView: MagnifierView!
    /// All polygon layers inside the view.
    var polygonLayers: [PolygonLayer] = []
    /// The currently selected polygon point.
    var selectedControlPointLayer: ControlPointLayer?
    /// The currently selected polygon layer.
    var selectedPolygonLayer: PolygonLayer?

    // MARK: - Instance Methods -

    /// Adds a new polygon into the view.
    /// - Parameters:
    ///   - initialPoints: The initial points of the polygon.
    ///   - polygonConfiguration: The drawing configuration for the polygon.
    ///   - pointsConfiguration: The drawing configuration for the control points (polygon corners).
    public func addPolygon(initialPoints: [CGPoint], polygonConfiguration: PolygonLayerConfiguration? = nil, pointsConfiguration: ControlPointLayerConfiguration? = nil) {

        let polygonLayer = PolygonLayer(initialPoints: initialPoints, polygonConfiguration: polygonConfiguration, pointsConfiguration: pointsConfiguration)
        polygonLayer.contentsScale = UIScreen.main.scale
        polygonLayer.bounds = self.bounds
        polygonLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        self.polygonLayers.append(polygonLayer)
        self.layer.addSublayer(polygonLayer)
    }

    public func updatePolygonLayersFrame(_ frame: CGRect) {
        self.polygonLayers.forEach {
            $0.frame = frame
            $0.bounds = CGRect(origin: .zero, size: frame.size)
            $0.position = CGPoint(x: $0.bounds.midX, y: $0.bounds.midY)
        }
    }

    private func updateMagnifiedView() {
        if let magnifiedView = self.magnifiedView {
            if magnifierView == nil {
                magnifierView = MagnifierView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
                magnifierView.shape = .round
                magnifierView.isHidden = true
                magnifierView.translatesAutoresizingMaskIntoConstraints = false
                magnifierView.layer.borderColor = UIColor.white.cgColor
                magnifierView.layer.borderWidth = 2
                self.addSubview(magnifierView)
            }
            magnifierView.magnifiedView = magnifiedView
        }
    }

    // MARK: - Instance Methods [Touch Events] -

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard var point = touches.first?.location(in: self) else {
            return
        }

        let layerTransform = self.layer.affineTransform()

        for polygon in self.polygonLayers {
            if let selectedPoint = polygon.sublayers?.first(where: { $0.hitTest(point) != nil }) as? ControlPointLayer {
                point = CGPoint(x: (point.x * layerTransform.a) + self.frame.origin.x, y: (point.y * layerTransform.d) + self.frame.origin.y)
                self.selectedControlPointLayer = selectedPoint
                self.selectedControlPointLayer?.selected = true
                self.selectedPolygonLayer = polygon
                self.selectedPolygonLayer?.selected = true
                self.magnifierView?.isHidden = false
                self.magnifierView?.touchCenterView.isHidden = false
                self.magnifierView?.touchCenterView.center = point
                self.magnifierView?.touchLocation = point
            }
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.magnifierView?.isHidden = true
        self.magnifierView?.touchCenterView.isHidden = true
        self.selectedControlPointLayer?.selected = false
        self.selectedControlPointLayer = nil
        self.selectedPolygonLayer?.selected = false
        self.selectedPolygonLayer = nil
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard var point = touches.first?.location(in: self),
            let polygonLayer = self.selectedPolygonLayer,
            let pointLayer = self.selectedControlPointLayer else {
            return
        }

        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        if point.x >= polygonLayer.frame.minX &&
            point.y >= polygonLayer.frame.minY &&
            point.x <= polygonLayer.frame.maxX &&
            point.y <= polygonLayer.frame.maxY {
            pointLayer.position = point
            polygonLayer.updatePath()
        }
        CATransaction.commit()

        guard let magnifierView = self.magnifierView else {
            return
        }

        if magnifierView.frame.contains(point) {
            let xCoord = magnifierView.frame.origin.x == 0 ? self.frame.size.width - 100 : 0
            let newPosition = CGPoint(x: xCoord, y: 0)
            UIView.animate(withDuration: 0.25, animations: {
                magnifierView.frame = CGRect(origin: newPosition, size: magnifierView.frame.size)
                magnifierView.layoutIfNeeded()
            })
        }

        let layerTransform = self.layer.affineTransform()
        point = CGPoint(x: (point.x * layerTransform.a) + self.frame.origin.x, y: (point.y * layerTransform.d) + self.frame.origin.y)
        magnifierView.touchLocation = point
        self.magnifierView?.touchCenterView.center = point

    }
}
