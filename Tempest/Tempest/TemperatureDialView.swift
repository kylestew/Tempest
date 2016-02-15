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
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
    }
   
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    
        backgroundColor = UIColor.clearColor()
        self.clipsToBounds = false
    }

    override func drawRect(rect: CGRect) {
        drawWidget(rect, backColor: UIColor(red: 0.239, green: 0.549, blue: 0.973, alpha: 1.000))
    }
    
    // MARK: COPY/PASE from PaintCode
    func drawWidget(rect: CGRect, backColor: UIColor) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        let color = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.880)
        
        //// Shadow Declarations
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        shadow.shadowOffset = CGSizeMake(4.1, 4.1)
        shadow.shadowBlurRadius = 14
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalInRect: CGRectMake(rect.minX + 15, rect.minY + 15, rect.width - 30, rect.height - 30))
        CGContextSaveGState(context)
        CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, (shadow.shadowColor as! UIColor).CGColor)
        backColor.setFill()
        ovalPath.fill()
        CGContextRestoreGState(context)
        
        
        
        //// Oval 2 Drawing
        let oval2Path = UIBezierPath(ovalInRect: CGRectMake(rect.minX + 42.5, rect.minY + 42.5, 215.5, 215.5))
        color.setStroke()
        oval2Path.lineWidth = 3
        oval2Path.stroke()
        
        
        //// Rectangle Drawing
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, rect.minX + 99.85, rect.minY + 245.5)
        CGContextRotateCTM(context, -60 * CGFloat(M_PI) / 180)
        
        let rectanglePath = UIBezierPath(rect: CGRectMake(-12, -0.5, 24, 1))
        color.setStroke()
        rectanglePath.lineWidth = 3
        rectanglePath.stroke()
        
        CGContextRestoreGState(context)
        
        
        //// Rectangle 2 Drawing
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, rect.minX + 201.93, rect.minY + 245.86)
        CGContextRotateCTM(context, 60 * CGFloat(M_PI) / 180)
        
        let rectangle2Path = UIBezierPath(rect: CGRectMake(-12, -0.5, 24, 1))
        color.setStroke()
        rectangle2Path.lineWidth = 3
        rectangle2Path.stroke()
        
        CGContextRestoreGState(context)
    }
    
}

