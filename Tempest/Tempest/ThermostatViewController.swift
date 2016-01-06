import UIKit

class ThermostatViewController: UIViewController, AuthDelegate, ThermostatDelegate {
    
    var thermostat = Thermostat()
    
    @IBOutlet weak var masterControlButton: UIButton!
    @IBOutlet weak var fanAutoButton: UIButton!
    @IBOutlet weak var fan0Button: UIButton!
    @IBOutlet weak var fan1Button: UIButton!
    @IBOutlet weak var fan2Button: UIButton!
    @IBOutlet weak var fan3Button: UIButton!
    
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
            case .Heat:
                self.view.backgroundColor = UIColor(hex: 0xfe9964)
            case .Off:
                self.view.backgroundColor = UIColor(hex: 0xadadad)
            }
        }
        thermostat.fanSpeed.producer.startWithNext { fanSpeed in
//            self.fanSpeedSegmentedControl.selectedSegmentIndex = fanSpeed.rawValue
            
            if (fanSpeed == .Auto) {
                self.fanAutoButton.layer.borderWidth = 2.0
                self.fanAutoButton.enabled = true
                
            } else {
                self.fanAutoButton.layer.borderWidth = 0
                self.fanAutoButton.enabled = false
                
            }
            
            print("FAN: \(fanSpeed)")
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
