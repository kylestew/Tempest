import Foundation

struct Thermostat {
    
    var sparkId:String {
        didSet {
            NSUserDefaults.standardUserDefaults().setValue(sparkId, forKey: "spark_id")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    init() {
        if let sid = NSUserDefaults.standardUserDefaults().stringForKey("spark_id") {
           sparkId = sid
        } else {
            sparkId = ""
        }
    }
    
    init(sparkId: String) {
        self.sparkId = sparkId
    }

}
