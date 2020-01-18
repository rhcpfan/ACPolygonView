//
//  PolygonView.swift
//  PolygonView
//
//  Created by Andrei Ciobanu on 03/11/2019.
//  Copyright © 2019 Andrei Ciobanu. All rights reserved.
//

import UIKit
import AVFoundation

public protocol PolygonViewDelegate: class {
    func didSelectCorner(atLocation: CGPoint)
    func didDeselectCorner(atLocation: CGPoint)
    func didMoveCorner(from:CGPoint, to: CGPoint)
}

public class PolygonView: UIView {

    // MARK: - Instance Properties -

    public var delegate: PolygonViewDelegate?
    public var magnifierParrentView: UIView?
    public var magnifierViewOrigin: CGPoint = .zero
    public var magnifierViewSize = CGSize(width: 100, height: 100)
    /// A magnifier view used to display a more precise location of the polygon points.
    public var magnifiedView: UIView? { didSet { self.updateMagnifiedView() }}
    /// A magnifier view used to display a more precise location of the polygon points.
    var magnifierView: MagnifierView!
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
            // Get the CGRect that represents the scaled image frame (image clipping rectangle)
            let imageClippingRect = AVMakeRect(aspectRatio: imageSize, insideRect: self.bounds)
            // Scale from original image size to the image clipping rectangle
            let scaleX = imageClippingRect.width / imageSize.width
            let scaleY = imageClippingRect.height / imageSize.height
            let layerOrigin = CGPoint(x: imageClippingRect.minX, y: imageClippingRect.minY)
            let layerSize = CGSize(width: imageSize.width * scaleX, height: imageSize.height * scaleY)
            let layerFrame = CGRect(origin: layerOrigin, size: layerSize)
            let scaleTransform = CATransform3DMakeScale(scaleX, scaleY, 1)
            polygonLayer.transform = scaleTransform
            // Move the layer position to the image clipping rectangle origin
            polygonLayer.frame = layerFrame
        }
    }

    /// Initializes the magnifier view (round shape, displayed at the top-left corner of the image view frame)
    private func initMagnifierView() {
        magnifierView = MagnifierView(frame: CGRect(origin: magnifierViewOrigin, size: magnifierViewSize))
        magnifierView.shape = .round
        magnifierView.isHidden = true
        magnifierView.translatesAutoresizingMaskIntoConstraints = false
        magnifierView.layer.borderColor = UIColor.white.cgColor
        magnifierView.layer.borderWidth = 2
    }

    /// Updates the magnifier's view that needs to be magnified.
    private func updateMagnifiedView() {
        guard let magnifiedView = self.magnifiedView else {
            return
        }

        if magnifierView == nil {
            self.initMagnifierView()
            if let parrentView = magnifierParrentView {
                parrentView.addSubview(magnifierView)
            } else {
                self.addSubview(magnifierView)
            }
        }
        magnifierView.frame = CGRect(origin: magnifierViewOrigin, size: magnifierViewSize)
        magnifierView.magnifiedView = magnifiedView
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

    // MARK: - Instance Methods [Touch Events] -

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        guard let polygonLayer = self.polygonLayers.first else {
            return
        }

        let viewPoint = firstTouch.location(in: self)
        let scaledPoint = getPositionFor(point: viewPoint, inLayer: polygonLayer)

        for polygon in self.polygonLayers {
            if let selectedPoint = polygon.sublayers?.first(where: { $0.hitTest(scaledPoint) != nil }) as? ControlPointLayer {
                self.selectedControlPointLayer = selectedPoint
                self.selectedControlPointLayer?.selected = true
                self.selectedPolygonLayer = polygon
                self.selectedPolygonLayer?.selected = true

                self.delegate?.didSelectCorner(atLocation: scaledPoint)
                DispatchQueue.main.async {
                    self.magnifierView?.isHidden = false
                    self.magnifierView?.touchCenterView.isHidden = false
                    self.magnifierView?.layoutIfNeeded()
                }
                self.magnifierView?.touchCenterView.center = viewPoint
                self.magnifierView?.touchLocation = viewPoint
            }
        }
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstTouch = touches.first else { return }
        guard let polygonLayer = self.selectedPolygonLayer else {
            return
        }

        let viewPoint = firstTouch.location(in: self)
        let scaledPoint = getPositionFor(point: viewPoint, inLayer: polygonLayer)

        DispatchQueue.main.async {
            self.magnifierView?.isHidden = true
            self.magnifierView?.touchCenterView.isHidden = true
            self.magnifierView?.layoutIfNeeded()
        }

        self.selectedControlPointLayer?.selected = false
        self.selectedPolygonLayer?.selected = false
        self.selectedControlPointLayer = nil
        self.selectedPolygonLayer = nil

        self.delegate?.didDeselectCorner(atLocation: scaledPoint)
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let firstTouch = touches.first else { return }

        guard let polygonLayer = self.selectedPolygonLayer,
            let pointLayer = self.selectedControlPointLayer else {
            return
        }

        let prevTouchLocation = firstTouch.previousLocation(in: self)
        let newTouchLocation = firstTouch.location(in: self)
        let prevTouchLocationInLayer = getPositionFor(point: prevTouchLocation, inLayer: polygonLayer)
        let newTouchLocationInLayer = getPositionFor(point: newTouchLocation, inLayer: polygonLayer)

        let layerOrigin = polygonLayer.frame.origin
        let layerWidth = polygonLayer.frame.width * (1.0 / polygonLayer.transform.m11)
        let layerHeight = polygonLayer.frame.height * (1.0 / polygonLayer.transform.m22)

        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        if newTouchLocation.x >= layerOrigin.x &&
            newTouchLocation.y >= layerOrigin.y &&
            newTouchLocationInLayer.x <= layerWidth &&
            newTouchLocationInLayer.y <= layerHeight {
            pointLayer.position = newTouchLocationInLayer
            polygonLayer.updatePath()
            self.delegate?.didMoveCorner(from: prevTouchLocationInLayer, to: newTouchLocationInLayer)
        }
        CATransaction.commit()


        guard let magnifierView = self.magnifierView else {
            return
        }

        let parrentView = magnifierParrentView ?? self
        let parrentViewPoint = firstTouch.location(in: parrentView)
        if magnifierView.frame.contains(parrentViewPoint) {
            let currentMagnifierViewOrigin = magnifierView.frame.origin
            let magnifierViewWidth = magnifierView.bounds.width
            var xCoord = magnifierViewOrigin.x
            if currentMagnifierViewOrigin.x == magnifierViewOrigin.x {
                xCoord = parrentView.bounds.size.width - magnifierViewWidth - magnifierViewOrigin.x
            }

            let newPosition = CGPoint(x: xCoord, y: magnifierViewOrigin.y)
            UIView.animate(withDuration: 0.25, animations: {
                magnifierView.frame = CGRect(origin: newPosition, size: magnifierView.frame.size)
                magnifierView.layoutIfNeeded()
            })
        }

        magnifierView.touchLocation = newTouchLocation
        self.magnifierView?.touchCenterView.center = newTouchLocation
    }
}
