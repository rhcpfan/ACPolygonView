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
            CGPoint(x: 25, y: 95),
            CGPoint(x: 180, y: 15),
            CGPoint(x: 340, y: 100),
            CGPoint(x: 170, y: 200)
        ]

        let secondPolyPoints = [
            CGPoint(x: 125, y: 95),
            CGPoint(x: 80, y: 150),
            CGPoint(x: 240, y: 100),
            CGPoint(x: 270, y: 200)
        ]

        self.polygonView.magnifiedView = self.imageView
        self.addPolygon(points: firstPolyPoints)
        self.addPolygon(points: secondPolyPoints)
        self.updateLayerBounds()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: { context in
            self.updateLayerBounds()
        })
    }

    // MARK: - Instance Methods -

    func updateLayerBounds() {
        if imageView.contentMode == .scaleAspectFit, let displayedImage = imageView.image {
            let imageClippingRect = AVMakeRect(aspectRatio: displayedImage.size, insideRect: imageView.bounds)
            self.polygonView.translatesAutoresizingMaskIntoConstraints = false
            self.polygonView.frame = imageClippingRect
            self.polygonView.updatePolygonLayersFrame(imageClippingRect)
            self.polygonView.layer.frame = imageClippingRect
            self.polygonView.layer.bounds = CGRect(origin: .zero, size: imageClippingRect.size)
        }
    }

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
