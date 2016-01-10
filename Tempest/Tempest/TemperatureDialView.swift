import UIKit

@IBDesignable
class TemperatureDialView: UIView {
    
    var thermostat:Thermostat? {
        didSet {
            print(thermostat)
//        thermostat.temperature.producer.startWithNext { (temperature) -> () in
//            self.actualTempLabel.text = String(format: "%0.0f", temperature)
//        }
//        thermostat.targetTemp.producer.startWithNext { (target) -> () in
//            self.targetTempLabel.text = String(format: "%d", target)
//        }
        }
    }
    
    // TODO: add gesture input for temp change
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        prepareUI()
//    }
//   
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        prepareUI()
//    }
//    
//    func prepareUI() {
//    }
    
    var trackLayer = CAShapeLayer()
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        
        if (layer != self.layer) {
            print("ADFSADFS")
        }
        
        // DIAL TRACK
        // need to redo shape size
        let shrink = bounds.size.width - CGFloat(round(bounds.size.width * 0.9))
        let rect = CGRectInset(bounds, shrink, shrink)
        let path = UIBezierPath(ovalInRect: rect)
        // TODO: add tick marks?
        trackLayer.path = path.CGPath
        trackLayer.fillColor = UIColor.clearColor().CGColor
        trackLayer.strokeColor = UIColor(white: 1.0, alpha: 0.35).CGColor
        trackLayer.lineWidth = 3.0
        // reframe
        trackLayer.frame = layer.bounds
        if (trackLayer.superlayer != layer) {
            layer.addSublayer(trackLayer)
        }
        
        
        // TODO:
        // current temp tick mark
        // current temp set control point
        
        
    }
    
    var setToLabel = UILabel()
    var setTempLabel = UILabel()
    var currentTempLabel = UILabel()
    
    override func layoutSubviews() {
        // style main dial
        backgroundColor = UIColor(hex: 0x3d8cf8)
        layer.cornerRadius = self.frame.size.width/2.0
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSizeMake(4, 4)
        layer.shadowRadius = 14.0
        
        // SET TO
        if (setToLabel.superview != self) {
            setToLabel.text = "SET TO"
            setToLabel.textAlignment = .Center
            self.addSubview(setToLabel)
        }
        setToLabel.frame = CGRectMake(self.center.x-40.0, self.center.y-80.0, 80.0, 32.0)
        setToLabel.backgroundColor = UIColor.redColor()
        
        // CURRENT SET
        
        // CURRENT TEMP MARK
        // tricky circle math
        
        
        
        
        
    }
    
}
