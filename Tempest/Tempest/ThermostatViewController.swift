import UIKit

class ThermostatViewController: UIViewController, AuthDelegate, ThermostatDelegate {
    
    var thermostat = Thermostat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thermostat.temperature.producer.startWithNext { (temperature) -> () in
            print("temp: \(temperature)")
        }
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
    
    
    @IBAction func action(sender: AnyObject) {
        thermostat.changeTargetTemperature(72)
        thermostat.changeMasterMode(0)
        thermostat.changeFanSpeed(0)
    }
    
    
}
