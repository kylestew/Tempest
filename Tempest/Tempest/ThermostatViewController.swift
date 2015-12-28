import UIKit

class ThermostatViewController: UIViewController, AuthDelegate, ThermostatDelegate {
    
    var thermostat = Thermostat()
    
    @IBOutlet weak var actualTempLabel: UILabel!
    @IBOutlet weak var targetTempLabel: UILabel!
    @IBOutlet weak var masterControlButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thermostat.temperature.producer.startWithNext { (temperature) -> () in
            self.actualTempLabel.text = String(format: "%0.0f", temperature)
        }
        thermostat.targetTemp.producer.startWithNext { (target) -> () in
            self.targetTempLabel.text = String(format: "%d", target)
        }
        thermostat.masterControl.producer.startWithNext{ mode in
            self.masterControlButton.setTitle(mode.displayName(), forState: .Normal)
        }
        // FAN
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
       
        // check if logged in
        if (!SparkCloud.sharedInstance().isLoggedIn) {
            // popup auth
            showAuth()
        } else {
            thermostat.delegate = self
            thermostat.connect()
        }
    }
    
    func showAuth() {
        let auth = AuthViewController.createWithDelegate(self)
        presentViewController(auth, animated: true, completion: nil)
    }
    
    func didAuthWithDevice(device: SparkDevice) {
        thermostat.sparkId = device.id
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
        let actionSheet = UIAlertController(title: "Master Control", message: nil, preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Heat", style: .Default, handler: { action in
            self.thermostat.changeMasterMode(.Heating)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cool", style: .Default, handler: { action in
            self.thermostat.changeMasterMode(.Cooling)
        }))
        actionSheet.addAction(UIAlertAction(title: "Off", style: .Default, handler: { action in
            self.thermostat.changeMasterMode(.Off)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func changeFanSpeed(sender: UISegmentedControl) {
        if let speed = FanSpeeds(rawValue: sender.selectedSegmentIndex) {
            thermostat.changeFanSpeed(speed)
        }
    }
}
