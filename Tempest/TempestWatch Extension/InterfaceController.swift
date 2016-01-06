import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var temperatureLabel: WKInterfaceLabel!
    @IBOutlet var targetTempPicker: WKInterfacePicker!
    
    var temperature = 0.0
    var targetTemp = 0
    var selectedTarget = 0
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let session = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()
        
        // set picker items: 64-88 deg
        var pickerItems:[WKPickerItem] = []
        for var i = 64; i <= 88; i+=2 {
            let item = WKPickerItem()
            item.title = "\(i)"
            item.caption = "target temp"
            pickerItems.append(item)
        }
        targetTempPicker.setItems(pickerItems)
        
        updateUI()
    }
    
    func updateUI() {
        temperatureLabel.setText(String(format: "%0.0f", temperature))
        let target = Int((targetTemp-64)/2)
        if target > 0 {
            targetTempPicker.setSelectedItemIndex(target)
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        if let temp = applicationContext["temperature"] as? Double {
            temperature = temp
        }
        if let temp = applicationContext["targetTemp"] as? Int {
            targetTemp = temp
        }
        updateUI()
    }

    @IBAction func setTemperature() {
        let session = WCSession.defaultSession()
        var context = session.applicationContext
        context["targetTemp"] = (selectedTarget*2)+64
        do {
            try session.updateApplicationContext(context)
        } catch let error {
            print(error)
        }
    }
    
    @IBAction func pickerDidChange(value: Int) {
        selectedTarget = value
    }
}
