import UIKit

class ThermostatViewController: UIViewController, AuthDelegate {
    
    var thermostat = Thermostat()
    var sparkDevice:SparkDevice?

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // check if logged in
        if (!SparkCloud.sharedInstance().isLoggedIn || thermostat.sparkId == "") {
            // popup auth
            showAuth()
        } else {
            // try to connect to device
            SparkCloud.sharedInstance().getDevice(thermostat.sparkId) { (sparkDevice, error) -> Void in
                if sparkDevice == nil {
                    print(error)
                    self.showAuth()
                } else {
                    self.sparkDevice = sparkDevice
                    self.bindView()
                }
            }
        }
    }
    
    func showAuth() {
        let auth = AuthViewController.createWithDelegate(self)
        presentViewController(auth, animated: true, completion: nil)
    }
    
    func didAuthWithDevice(device: SparkDevice) {
        thermostat.sparkId = device.id
        sparkDevice = device
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func bindView() {
        print(sparkDevice)
    }
    
}
