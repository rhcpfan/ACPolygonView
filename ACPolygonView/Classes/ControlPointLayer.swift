//
//  ControlPointLayer.swift
//  PolygonView
//
//  Created by Andrei Ciobanu on 03/11/2019.
//  Copyright © 2019 Andrei Ciobanu. All rights reserved.
//

import UIKit

class ControlPointLayer: CAShapeLayer {
    
    // MARK: - Instance Properties -

    /// Configuration object for drawing the control point layer.
    var configuration: ControlPointLayerConfiguration
    /// Control point layer selection state.
    var selected: Bool = false {
        didSet { self.updateState(isSelected: selected) }
    }

    // MARK: - Initializers -

    init(config: ControlPointLayerConfiguration? = nil) {
        self.configuration = config ?? .default
        super.init()
        self.updateState(isSelected: self.selected)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: Any) {
        if let polygonLayer = layer as? ControlPointLayer {
            self.configuration = polygonLayer.configuration
        } else {
            self.configuration = .default
        }
        super.init(layer: layer)
    }

    // MARK: - Instance Methods -

    /// Updates the drawing properties (`.fillColor`, `.strokeColor` and `.lineWidth`) based on the `isSelected` state.
    /// - Parameter isSelected: The current selection state of the polygon.
    func updateState(isSelected: Bool) {
        self.fillColor = isSelected ? self.configuration.selectedFillColor.cgColor : self.configuration.fillColor.cgColor
        self.strokeColor = isSelected ? self.configuration.selectedLineColor.cgColor : self.configuration.lineColor.cgColor
        self.lineWidth = isSelected ? self.configuration.selectedLineWidth : self.configuration.lineWidth
    }
}
