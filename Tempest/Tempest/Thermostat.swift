import Foundation
import ReactiveCocoa

protocol ThermostatDelegate {
    func thermostatDidDisconnect()
}

class Thermostat {
    var temperature = MutableProperty<Double>(0.0)
    var masterControl = MutableProperty<Int>(2)
    var targetTemp = MutableProperty<Int>(70)
    var fanSpeed = MutableProperty<Int>(1)
    
    var delegate:ThermostatDelegate?
    var sparkDevice:SparkDevice?
    var sparkId:String {
        didSet {
            NSUserDefaults.standardUserDefaults().setValue(sparkId, forKey: "spark_id")
            NSUserDefaults.standardUserDefaults().synchronize()
            connect()
        }
    }
    
    init() {
        if let sid = NSUserDefaults.standardUserDefaults().stringForKey("spark_id") {
           sparkId = sid
        } else {
            sparkId = ""
        }
        
        // start update loops
        NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("processSettingsQueue"), userInfo: nil, repeats: true)
        NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: Selector("updateTemperature"), userInfo: nil, repeats: true)
    }
    
    func connect() {
        if (sparkId == "") {
            delegate?.thermostatDidDisconnect()
            return
        }
        
        // try to connect to device
        SparkCloud.sharedInstance().getDevice(sparkId) { (sparkDevice, error) -> Void in
            if sparkDevice == nil {
                self.delegate?.thermostatDidDisconnect()
            } else {
                self.sparkDevice = sparkDevice
                self.updateTemperature()
            }
        }
    }
    
    // MARK: Temperature readings
    @objc func updateTemperature() {
        sparkDevice?.getVariable("temp", completion: { (result:AnyObject!, error:NSError!) -> Void in
            if (error != nil) {
                self.delegate?.thermostatDidDisconnect()
            } else {
                if let temp = result as? Double {
                    self.temperature.value = temp * 9.0/5 + 32.0
                }
            }
        })
    }
    
    // MARK: Settings accessors
    
        // TODO: bound all values
    
    func changeTargetTemperature(targetTemp: Int) {
        // tempertature: 64-88deg (will cap)
        self.targetTemp.value = targetTemp
        sendSettingsUpdate = true
    }
    
    func changeMasterMode(masterMode: Int) {
        // masterControl: 0 - auto, 1 - cool, 2 - dry, 3 - fan, 4 - heat
        self.masterControl.value = masterMode
        sendSettingsUpdate = true
    }
    
    func changeFanSpeed(fanSpeed: Int) {
        // fanSpeed: 0 - auto, 1 - high, 2 - med, 3 - low, 4 - quiet
        self.fanSpeed.value = fanSpeed
        sendSettingsUpdate = true
    }
    
    // MARK: Settings update queue
    var sendSettingsUpdate = false
    @objc private func processSettingsQueue() {
        if (sendSettingsUpdate) {
            
//            sparkDevice?.callFunction("turnOff", withArguments:nil, completion: { (resultCode : NSNumber!, error : NSError!) -> Void in
//                if (error != nil) {
//                    self.delegate?.thermostatDidDisconnect()
//                }
//            })
            
            let args = [ "\(masterControl.value),\(targetTemp.value),\(fanSpeed.value)" ];
            
            print("sending: \(args)")
            sparkDevice?.callFunction("writeTo", withArguments:args, completion: { (resultCode : NSNumber!, error : NSError!) -> Void in
                if (error != nil) {
                    print(error)
//                    self.delegate?.thermostatDidDisconnect()
                }
            })
        
            sendSettingsUpdate = false
        }
    }
    
}
