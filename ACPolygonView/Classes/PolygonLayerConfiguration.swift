//
//  PolygonLayerConfiguration.swift
//  PolygonView
//
//  Created by Andrei Ciobanu on 03/11/2019.
//  Copyright © 2019 Andrei Ciobanu. All rights reserved.
//

import UIKit

public class PolygonLayerConfiguration: NSObject {

    /// The width of the line used to draw the polygon (normal state).
    public var lineWidth: CGFloat = 3.0
    /// The color of the line used to draw the polygon (normal state).
    public var lineColor: UIColor = .red
    /// The color used to fill the polygon (normal state).
    public var fillColor: UIColor = .yellow
    /// The width of the line used to draw the polygon (selected state).
    public var selectedLineWidth: CGFloat = 3.0
    /// The color of the line used to draw the polygon (selected state).
    public var selectedLineColor: UIColor = .red
    /// The color used to fill the polygon (selected state).
    public var selectedFillColor: UIColor = .yellow

    /// Default configuration for drawing a polygon layer.
    open class var `default`: PolygonLayerConfiguration {
        return PolygonLayerConfiguration()
    }
}
