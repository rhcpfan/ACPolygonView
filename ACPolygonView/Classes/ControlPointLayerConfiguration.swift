//
//  ControlPointLayerConfiguration.swift
//  PolygonView
//
//  Created by Andrei Ciobanu on 03/11/2019.
//  Copyright © 2019 Andrei Ciobanu. All rights reserved.
//

import UIKit

public class ControlPointLayerConfiguration: NSObject {

    /// The radius of the control points (normal state).
    public var radius: CGFloat = 30
    /// The width of the line used to draw the control point (normal state).
    public var lineWidth: CGFloat = 3.0
    /// The color of the line used to draw the control point (normal state).
    public var lineColor: UIColor = .green
    /// The color used to fill the control point (normal state).
    public var fillColor: UIColor = .blue
    /// The radius of the control points (normal state).
    public var selectedRadius: CGFloat = 40
    /// The width of the line used to draw the control point (selected state).
    public var selectedLineWidth: CGFloat = 3.0
    /// The color of the line used to draw the control point (selected state).
    public var selectedLineColor: UIColor = .green
    /// The color used to fill the control point (selected state).
    public var selectedFillColor: UIColor = .blue

    /// Default configuration for drawing a control point layer.
    open class var `default`: ControlPointLayerConfiguration {
        return ControlPointLayerConfiguration()
    }
}
