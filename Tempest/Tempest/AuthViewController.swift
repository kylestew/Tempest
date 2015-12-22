import UIKit

protocol AuthDelegate {
    func didAuthWithDevice(device: SparkDevice)
}

class AuthViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var authDelegate:AuthDelegate?
    
    class func createWithDelegate(authDelegate: AuthDelegate) -> AuthViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("auth") as! AuthViewController
        vc.authDelegate = authDelegate
        return vc
    }
    
    @IBAction func auth(sender: AnyObject) {
        SparkCloud.sharedInstance().loginWithUser(email.text, password: password.text) { (error:NSError!) -> Void in
            if (error != nil) {
                let alert = UIAlertController(title: "Login Error", message: "Could not login", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                // auth successful - ask user which device to use
                self.selectDevice()
            }
        }
    }
        
    func selectDevice() {
        SparkCloud.sharedInstance().getDevices { (sparkDevices:[AnyObject]!, error:NSError!) -> Void in
            if (error != nil) {
                let alert = UIAlertController(title: "Device Enumeration Error", message: "Could not list your devices", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let actionSheet = UIAlertController(title: "Pick Device", message: nil, preferredStyle: .ActionSheet)
                if let devices = sparkDevices as? [SparkDevice] {
                    for device in devices {
                        let action = UIAlertAction(title: device.name, style: .Default, handler: { action in
                            if let delegate = self.authDelegate {
                                delegate.didAuthWithDevice(device)
                            }
                        })
                        actionSheet.addAction(action)
                    }
                    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                }
                self.presentViewController(actionSheet, animated: true, completion: nil)
            }
        }
    }
    
}
