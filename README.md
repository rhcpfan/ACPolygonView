# ACPolygonView

<div>
    <div>
        <img src="https://user-images.githubusercontent.com/3796970/68125913-54000c80-ff1b-11e9-89ab-4564619fb701.png" width="200">
    </div>
    <div>
        <img src="https://user-images.githubusercontent.com/3796970/68125875-3cc11f00-ff1b-11e9-81f0-6339f0c194a2.png" width="200">
    </div>
</div>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- iOS 8.0

## Installation

ACPolygonView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ACPolygonView'
```

## Example of Usage


```swift
import UIKit
import ACPolygonView

class ViewController: UIViewController {
  
    @IBOutlet weak var imageView: UIImageView! // display an image
    @IBOutlet weak var polygonView: PolygonView! // has the same frame as imageView

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstPolyPoints = [
            CGPoint(x: 25, y: 95),
            CGPoint(x: 180, y: 15),
            CGPoint(x: 340, y: 100),
            CGPoint(x: 170, y: 200)
        ]
        
        // If magnifiedView is set, a magnifier view will be displayed in 
        // the top-left corner of polygonView, displaying the content of imageView
        self.polygonView.magnifiedView = self.imageView 
        self.addPolygon(points: firstPolyPoints)
    }
    
    /// Adds a polygon inside polygonView
    /// - Parameter points: The initial points of the polygon.
    func addPolygon(points: [CGPoint]) {
        // Drawing configuration for the polygon layer
        let polyConfig = PolygonLayerConfiguration()
        polyConfig.fillColor = UIColor(red: 0.5, green: 1, blue: 0.0, alpha: 0.5)
        polyConfig.selectedFillColor = UIColor.yellow.withAlphaComponent(0.5)
        polyConfig.lineColor = .clear
        polyConfig.selectedLineColor = .clear
        
        // Drawing configuration for all the control point layers (polygon corners)
        let pointsConfig = ControlPointLayerConfiguration()
        pointsConfig.fillColor = .clear
        pointsConfig.selectedFillColor = .clear
        pointsConfig.lineColor = .white
        pointsConfig.selectedLineColor = .red
        
        // Add the polygon layer as a sublayer of polygonView
        self.polygonView.addPolygon(initialPoints: points, polygonConfiguration: polyConfig, pointsConfiguration: pointsConfig)
    }
}
```

## Author

Andrei Ciobanu, ac.ciobanu@yahoo.com

## License

ACPolygonView is available under the MIT license. See the LICENSE file for more info.
