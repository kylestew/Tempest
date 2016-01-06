import UIKit

class ThermostatViewController: UIViewController, AuthDelegate, ThermostatDelegate {
    
    var thermostat = Thermostat()
    
    @IBOutlet weak var masterControlButton: UIButton!
    @IBOutlet weak var fanAutoButton: UIButton!
    @IBOutlet weak var fan0Button: UIButton!
    @IBOutlet weak var fan1Button: UIButton!
    @IBOutlet weak var fan2Button: UIButton!
    @IBOutlet weak var fan3Button: UIButton!
    var fanButtons:[UIButton]!
    
//    @IBOutlet weak var actualTempLabel: UILabel!
//    @IBOutlet weak var targetTempLabel: UILabel!
//    @IBOutlet weak var fanSpeedSegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // further styling
        masterControlButton.layer.borderColor = UIColor.whiteColor().CGColor
        masterControlButton.layer.borderWidth = 2.0
        masterControlButton.layer.cornerRadius = 2.0
        fanAutoButton.layer.borderColor = UIColor.whiteColor().CGColor
        fanAutoButton.layer.borderWidth = 2.0
        fanAutoButton.layer.cornerRadius = 2.0
        
        // easy access
        fanButtons = [ fan0Button, fan1Button, fan2Button, fan3Button ]
        
        
//        thermostat.temperature.producer.startWithNext { (temperature) -> () in
//            self.actualTempLabel.text = String(format: "%0.0f", temperature)
//        }
//        thermostat.targetTemp.producer.startWithNext { (target) -> () in
//            self.targetTempLabel.text = String(format: "%d", target)
//        }
        
        thermostat.masterControl.producer.startWithNext { mode in
            self.masterControlButton.setTitle(mode.displayName().uppercaseString, forState: .Normal)
            switch (mode) {
            case .Cool:
                self.view.backgroundColor = UIColor(hex: 0x71a5f7)
                self.fanAutoButton.backgroundColor = UIColor(hex: 0x3989FC)
            case .Heat:
                self.view.backgroundColor = UIColor(hex: 0xfe9964)
                self.fanAutoButton.backgroundColor = UIColor(hex: 0xfa7036)
            case .Off:
                self.view.backgroundColor = UIColor(hex: 0xadadad)
            }
            
            // disable all fan speed buttons if master control is off
            let isOff = mode == .Off
            self.fanAutoButton.hidden = isOff
            for button in self.fanButtons { button.enabled = !isOff }
        }
        thermostat.fanSpeed.producer.startWithNext { fanSpeed in
            if (fanSpeed == .Auto) {
                self.fanAutoButton.layer.borderWidth = 2.0
                self.fanAutoButton.alpha = 1.0
                for button in self.fanButtons { button.alpha = 0.5 }
            } else {
                self.fanAutoButton.layer.borderWidth = 0
                self.fanAutoButton.alpha = 0.5
                var i = 1
                for button in self.fanButtons {
                    if i++ > FanSpeeds.Quiet.rawValue - fanSpeed.rawValue + 1 {
                        button.alpha = 0.5
                    } else {
                        button.alpha = 1.0
                    }
                }
            }
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       
        // check if logged in
        if (!SparkCloud.sharedInstance().isLoggedIn && !thermostat.isDemoMode) {
            // popup auth
            showAuth()
        } else {
            thermostat.delegate = self
            thermostat.connect()
        }
    }
    
    func showAuth() {
        let auth = AuthViewController.createWithDelegate(self)
        presentViewController(auth, animated: false, completion: nil)
    }
    
    func didAuthWithDevice(device: SparkDevice) {
        thermostat.sparkId = device.id
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didSelectDemoMode() {
        thermostat.isDemoMode = true
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func thermostatDidDisconnect() {
        showAuth()
    }
    
    // MARK: Actions
    @IBAction func targetIncrease(sender: AnyObject) {
        thermostat.incTargetTemp()
    }
    @IBAction func targetDecrease(sender: AnyObject) {
        thermostat.decTargetTemp()
    }
    
    @IBAction func setMode(sender: AnyObject) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Heat", style: .Default, handler: { action in
            self.thermostat.changeMasterMode(.Heat)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cool", style: .Default, handler: { action in
            self.thermostat.changeMasterMode(.Cool)
        }))
        actionSheet.addAction(UIAlertAction(title: "Off", style: .Default, handler: { action in
            self.thermostat.changeMasterMode(.Off)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func setFanToAuto(sender: AnyObject) {
        thermostat.changeFanSpeed(.Auto)
    }
    @IBAction func setFanToQuite(sender: AnyObject) {
        thermostat.changeFanSpeed(.Quiet)
    }
    @IBAction func setFanToLow(sender: AnyObject) {
        thermostat.changeFanSpeed(.Low)
    }
    @IBAction func setFanToMed(sender: AnyObject) {
        thermostat.changeFanSpeed(.Medium)
    }
    @IBAction func setFanToHigh(sender: AnyObject) {
        thermostat.changeFanSpeed(.High)
    }

}
