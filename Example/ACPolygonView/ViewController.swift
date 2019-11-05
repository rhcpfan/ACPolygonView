//
//  ViewController.swift
//  PolygonView
//
//  Created by Andrei Ciobanu on 03/11/2019.
//  Copyright © 2019 Andrei Ciobanu. All rights reserved.
//

import UIKit
import ACPolygonView
import AVFoundation

class ViewController: UIViewController {

    // MARK: - IBOutlets -

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var polygonView: PolygonView!

    // MARK: - Application Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let firstPolyPoints = [
            CGPoint(x: 150, y: 150),
            CGPoint(x: 450, y: 150),
            CGPoint(x: 450, y: 450),
            CGPoint(x: 150, y: 450)
        ]

        self.polygonView.magnifiedView = self.imageView
        self.addPolygon(points: firstPolyPoints)
        if let imageSize = self.imageView.image?.size {
            self.polygonView.updateFrameForPolygonLayers(toFitImageOfSize: imageSize)
        }
    }

    // MARK: - Instance Methods -

    /// Adds a polygon inside `polygonView`
    /// - Parameter points: The initial points of the polygon.
    func addPolygon(points: [CGPoint]) {
        let polyConfig = PolygonLayerConfiguration()
        polyConfig.fillColor = UIColor(red: 0.5, green: 1, blue: 0.0, alpha: 0.5)
        polyConfig.selectedFillColor = UIColor.yellow.withAlphaComponent(0.5)
        polyConfig.lineColor = .clear
        polyConfig.selectedLineColor = .clear

        let pointsConfig = ControlPointLayerConfiguration()
        pointsConfig.fillColor = .clear
        pointsConfig.selectedFillColor = .clear
        pointsConfig.lineColor = .white
        pointsConfig.selectedLineColor = .red

        self.polygonView.addPolygon(initialPoints: points, polygonConfiguration: polyConfig, pointsConfiguration: pointsConfig)
    }
}
