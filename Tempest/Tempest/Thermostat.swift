import Foundation
import ReactiveCocoa

protocol ThermostatDelegate {
    func thermostatDidDisconnect()
}

enum MasterModes: Int {
    // masterControl: 0 - auto, 1 - cool, 2 - dry, 3 - fan, 4 - heat
    case Off = -1
    case Heating = 0
    case Cooling = 1
    
    func displayName() -> String {
        switch self {
        case .Off:
            return "off"
        case .Heating:
            return "heating"
        case .Cooling:
            return "cooling"
        }
    }
}

enum FanSpeeds: Int {
    // fanSpeed: 0 - auto, 1 - high, 2 - med, 3 - low, 4 - quiet
    case Auto = 0
    case High = 1
    case Med = 2
    case Low = 3
    case Quiet = 4
}

class Thermostat {
    let kSparkId = "spark_id"
    let kStoredTemperatureValue = "stored_temperature_value"
    let kStoredTargetValue = "stored_target_value"
    let kStoredMasterControl = "stored_master_control"
    let kStoredFanSpeed = "stored_fan_speed"
    
    var temperature = MutableProperty<Double>(0.0)
    var targetTemp = MutableProperty<Int>(70)
    var masterControl = MutableProperty<MasterModes>(.Cooling)
    var fanSpeed = MutableProperty<FanSpeeds>(.Auto)
    
    var delegate:ThermostatDelegate?
    var sparkDevice:SparkDevice?
    var sparkId:String {
        didSet {
            NSUserDefaults.standardUserDefaults().setValue(sparkId, forKey: kSparkId)
            NSUserDefaults.standardUserDefaults().synchronize()
            connect()
        }
    }
    
    init() {
        if let sid = NSUserDefaults.standardUserDefaults().stringForKey(kSparkId) {
           sparkId = sid
        } else {
            sparkId = ""
        }
        
        // load cached values for immediate display
        let defs = NSUserDefaults.standardUserDefaults()
        self.temperature.value = defs.doubleForKey(kStoredTemperatureValue)
        if (defs.valueForKey(kStoredTargetValue) != nil) {
            self.targetTemp.value = NSUserDefaults.standardUserDefaults().integerForKey(kStoredTargetValue)
        }
        if (defs.valueForKey(kStoredMasterControl) != nil) {
            if let mode = MasterModes(rawValue: NSUserDefaults.standardUserDefaults().integerForKey(kStoredMasterControl)) {
                self.masterControl.value = mode
            }
        }
        if (defs.valueForKey(kStoredFanSpeed) != nil) {
            if let fanSpeed = FanSpeeds(rawValue: NSUserDefaults.standardUserDefaults().integerForKey(kStoredFanSpeed)) {
                self.fanSpeed.value = fanSpeed
            }
        }
        
        // start update loops
        NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("processSettingsQueue"), userInfo: nil, repeats: true)
        NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: Selector("updateTemperature"), userInfo: nil, repeats: true)
        
        // grab temperature right away
        updateTemperature()
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
                    NSUserDefaults.standardUserDefaults().setValue(self.temperature.value, forKey: self.kStoredTemperatureValue)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            }
        })
    }
    
    // MARK: Settings accessors
    func incTargetTemp() {
        changeTargetTemperature(self.targetTemp.value + 2)
    }
    func decTargetTemp() {
        changeTargetTemperature(self.targetTemp.value - 2)
    }
    private func changeTargetTemperature(targetTemp: Int) {
        // tempertature: 64-88deg (will cap)
        if (targetTemp >= 64 && targetTemp <= 88) {
            self.targetTemp.value = targetTemp
            sendSettingsUpdate()
            
            NSUserDefaults.standardUserDefaults().setValue(self.targetTemp.value, forKey: self.kStoredTargetValue)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func changeMasterMode(masterMode: MasterModes) {
        self.masterControl.value = masterMode
        sendSettingsUpdate()
        
        NSUserDefaults.standardUserDefaults().setInteger(self.masterControl.value.rawValue, forKey: self.kStoredMasterControl)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func changeFanSpeed(fanSpeed: FanSpeeds) {
        self.fanSpeed.value = fanSpeed
        sendSettingsUpdate()
        
        NSUserDefaults.standardUserDefaults().setInteger(self.fanSpeed.value.rawValue, forKey: self.kStoredFanSpeed)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // MARK: Settings update queue
    var hasSettingsUpdate = false
    var taskId:UIBackgroundTaskIdentifier?
    func sendSettingsUpdate() {
        hasSettingsUpdate = true
        // keep app alive even if backgrounded (3 seconds)
        taskId = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({})
    }
    
    @objc private func processSettingsQueue() {
        if (hasSettingsUpdate) {
            
            // TODO: handle OFF condition
//            sparkDevice?.callFunction("turnOff", withArguments:nil, completion: { (resultCode : NSNumber!, error : NSError!) -> Void in
//                if (error != nil) {
//                    self.delegate?.thermostatDidDisconnect()
//                }
//            })
            
            let args = [ "\(masterControl.value.rawValue),\(targetTemp.value),\(fanSpeed.value.rawValue)" ];
            
            print("sending: \(args)")
            sparkDevice?.callFunction("writeTo", withArguments:args, completion: { (resultCode : NSNumber!, error : NSError!) -> Void in
                if (error != nil) {
                    print(error)
//                    self.delegate?.thermostatDidDisconnect()
                }
            })
        
            hasSettingsUpdate = false
            if let task = taskId {
                UIApplication.sharedApplication().endBackgroundTask(task)
            }
        }
    }
    
}
