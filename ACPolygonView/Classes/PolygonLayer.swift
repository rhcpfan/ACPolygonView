//
//  PolygonLayer.swift
//  PolygonView
//
//  Created by Andrei Ciobanu on 03/11/2019.
//  Copyright © 2019 Andrei Ciobanu. All rights reserved.
//

import UIKit

class PolygonLayer: CAShapeLayer {

    // MARK: - Instance Properties -

    /// Configuration object for drawing the polygon layer.
    var polygonConfiguration: PolygonLayerConfiguration
    /// Configuration object for drawing the control point layers.
    var controlPointsConfiguration: ControlPointLayerConfiguration
    /// Polygon layer selection state.
    var selected: Bool = false {
        didSet { self.updateState(isSelected: selected) }
    }
    /// Array of `CGPoint` objects representing the polygon points.
    var points: [CGPoint] {
        return self.sublayers?.map({ $0.position }) ?? []
    }

    // MARK: - Initializers -

    init(initialPoints: [CGPoint], polygonConfiguration: PolygonLayerConfiguration? = nil, pointsConfiguration: ControlPointLayerConfiguration? = nil) {

        self.polygonConfiguration = polygonConfiguration ?? .default
        self.controlPointsConfiguration = pointsConfiguration ?? .default

        super.init()

        self.addControlPoints(initialPoints)
        self.updatePath()
        self.updateState(isSelected: self.selected)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: Any) {
        if let polygonLayer = layer as? PolygonLayer {
            self.polygonConfiguration = polygonLayer.polygonConfiguration
            self.controlPointsConfiguration = polygonLayer.controlPointsConfiguration
        } else {
            self.polygonConfiguration = .default
            self.controlPointsConfiguration = .default
        }
        super.init(layer: layer)
    }

    // MARK: - Instance Methods -

    /// Updates the polygon's `path` property, based on the control point layers.
    func updatePath() {
        guard self.points.count > 0 else {
            print("Add the control points before updating the layer path.")
            return
        }

        let path = UIBezierPath()
        let nrOfPoints = self.points.count

        path.move(to: self.points[0])
        for pIndex in 1 ..< nrOfPoints {
            path.addLine(to: self.points[pIndex])
        }

        path.close()
        self.path = path.cgPath
    }

    /// Adds one `ControlPointLayer` sublayer for each point in `initialPoints`.
    /// - Parameter initialPoints: The polygon initial points.
    func addControlPoints(_ initialPoints: [CGPoint]) {

        let pointOrigin = CGPoint(x: 0, y: 0)
        let pointSize = CGSize(width: 20, height: 20)
        let pointRect = CGRect(origin: pointOrigin, size: pointSize)

        initialPoints.forEach { point in
            let pointLayer = ControlPointLayer(config: controlPointsConfiguration)
            pointLayer.bounds = pointRect
            pointLayer.position = point
            pointLayer.path = UIBezierPath(ovalIn: pointRect).cgPath
            self.addSublayer(pointLayer)
        }
    }

    /// Updates the drawing properties (`.fillColor`, `.strokeColor` and `.lineWidth`) based on the `isSelected` state.
    /// - Parameter isSelected: The current selection state of the polygon.
    func updateState(isSelected: Bool) {
        self.fillColor = isSelected ? self.polygonConfiguration.selectedFillColor.cgColor : self.polygonConfiguration.fillColor.cgColor
        self.strokeColor = isSelected ? self.polygonConfiguration.selectedLineColor.cgColor : self.polygonConfiguration.lineColor.cgColor
        self.lineWidth = isSelected ? self.polygonConfiguration.selectedLineWidth : self.polygonConfiguration.lineWidth
    }
}
