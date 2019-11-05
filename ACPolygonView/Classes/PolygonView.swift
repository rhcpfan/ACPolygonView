//
//  PolygonView.swift
//  PolygonView
//
//  Created by Andrei Ciobanu on 03/11/2019.
//  Copyright © 2019 Andrei Ciobanu. All rights reserved.
//

import UIKit
import AVFoundation

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
        polygonLayer.frame = self.layer.frame
        self.layer.addSublayer(polygonLayer)
        self.polygonLayers.append(polygonLayer)
    }

    /// Returns the polyon corners for all the polygons contained inside.
    /// - Returns: Array of arrays of `CGPoint` (one aray of corner points for each polygon).
    public func getPolygonPoints() -> [[CGPoint]] {
        return self.polygonLayers.map({ $0.points })
    }

    /// Updates the layer of a polygon to match the original image that has been rendered using `.scaleAspectFit` (in size and coordinates).
    /// - Parameter polygonLayer: The layer to be modified.
    public func updateFrameForPolygonLayers(toFitImageOfSize imageSize: CGSize) {
        self.polygonLayers.forEach { (polygonLayer) in
            // Set the layer frame size as the original image size
            polygonLayer.frame = CGRect(origin: .zero, size: imageSize)
            // Get the CGRect that represents the scaled image frame (image clipping rectangle)
            let imageClippingRect = AVMakeRect(aspectRatio: imageSize, insideRect: self.bounds)
            // Scale from original image size to the image clipping rectangle
            let scaleX = imageClippingRect.width / imageSize.width
            let scaleY = imageClippingRect.height / imageSize.height
            let scaleTransform = CATransform3DMakeScale(scaleX, scaleY, 1)
            polygonLayer.transform = scaleTransform
            // Move the layer position to the image clipping rectangle origin
            polygonLayer.frame.origin = CGPoint(x: imageClippingRect.minX, y: imageClippingRect.minY)
        }
    }

    /// Initializes the magnifier view (round shape, displayed at the top-left corner of the image view frame)
    private func initMagnifierView() {
        magnifierView = MagnifierView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        magnifierView.shape = .round
        magnifierView.isHidden = true
        magnifierView.translatesAutoresizingMaskIntoConstraints = false
        magnifierView.layer.borderColor = UIColor.white.cgColor
        magnifierView.layer.borderWidth = 2
    }

    /// Updates the magnifier's view that needs to be magnified.
    private func updateMagnifiedView() {
        if let magnifiedView = self.magnifiedView {
            if magnifierView == nil {
                self.initMagnifierView()
                self.addSubview(magnifierView)
            }
            magnifierView.magnifiedView = magnifiedView
        }
    }

    /// Maps the given point to match the layer position and scale.
    /// - Parameters:
    ///   - point: The point to map.
    ///   - layer: The layer to do the mapping for.
    private func getPositionFor(point: CGPoint, inLayer layer: PolygonLayer) -> CGPoint {
        let translatedPoint = CGPoint(x: point.x - layer.frame.minX, y: point.y - layer.frame.minY)
        let layerTransform = layer.affineTransform()
        let scaledPoint = CGPoint(x: translatedPoint.x / layerTransform.a, y: translatedPoint.y / layerTransform.d)

        return scaledPoint
    }

    /// Returns the scale factors of the layer's affine transform.
    /// - Parameter layer: The layer to get the scale factors from.
    /// - Returns: A `(CGFloat, CGFloat)` tuple representing the `X` and `Y` scale factors.
    private func getScaleFactorsFor(layer: PolygonLayer) -> (xScale: CGFloat, yScale: CGFloat) {
        let layerTransform = layer.affineTransform()
        return (xScale: layerTransform.a, yScale: layerTransform.d)
    }

    // MARK: - Instance Methods [Touch Events] -

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self),
            let polygonLayer = self.polygonLayers.first else {
            return
        }

        let scaledPoint = getPositionFor(point: point, inLayer: polygonLayer)

        for polygon in self.polygonLayers {
            if let selectedPoint = polygon.sublayers?.first(where: { $0.hitTest(scaledPoint) != nil }) as? ControlPointLayer {
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
        guard let point = touches.first?.location(in: self),
            let polygonLayer = self.selectedPolygonLayer,
            let pointLayer = self.selectedControlPointLayer else {
            return
        }

        let scaledPoint = getPositionFor(point: point, inLayer: polygonLayer)
        let scaleFactors = getScaleFactorsFor(layer: polygonLayer)

        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        if scaledPoint.x >= 0 &&
            scaledPoint.y >= 0 &&
            scaledPoint.x <= polygonLayer.frame.width / scaleFactors.xScale &&
            scaledPoint.y <= polygonLayer.frame.height / scaleFactors.yScale {
            pointLayer.position = scaledPoint
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

        magnifierView.touchLocation = point
        self.magnifierView?.touchCenterView.center = point
    }
}
