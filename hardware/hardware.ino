#include <ESP8266WiFi.h>
#include <Wire.h>
#include <SparkFunHTU21D.h>

/* Wifi */
const char* ssid = "monkey_island";
const char* password = "monkeybusine$$";

/* Server API */
const char* serverUrl = "192.168.0.11";
#define PORT       3000

/* Pins */
/* HOOKUP GUIDE
*/
#define LED_INFO     5
#define IR_OUT       4

// default AC status
int temp = 0;
int fanSpeed = 0;

WiFiClient client;
HTU21D humidity;

unsigned long lastConnectionTime = 0; // last time you connected to the server, in milliseconds
const unsigned long pollingInterval = 10L * 1000L; // delay between updates, in milliseconds

void setup() {
//  Serial.begin(9600); 
  
  // LED INFO
  pinMode(LED_INFO, OUTPUT);
  digitalWrite(LED_INFO, LOW);
  
  // IR LED
//  pinMode(IR_OUT, OUTPUT);      
  
  humidity.begin();

  // boot up wifi
  byte ledStatus = LOW;
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.mode(WIFI_STA); // connect to local wifi, don't make an access point
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    // Blink the LED
    digitalWrite(LED_INFO, ledStatus); // Write LED high/low
    ledStatus = (ledStatus == HIGH) ? LOW : HIGH;
    
    // blocking loops will cause SOC to reset
    delay(100);
    Serial.print(".");
  }
  digitalWrite(LED_INFO, HIGH);
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void loop()  {
  digitalWrite(LED_INFO, HIGH); // reset
  
  delay(2000);

//  // any data to read?  
//  bool recording = false;
//  byte newTemp = 0;
//  byte newFanSpeed = 0;
//  while (client.available()) {
//    char c = client.read();
//    
//    if (c == '*' && recording) {
//      recording = false;
//      continue;
//    }
//
//    if (recording) {
//      if (newTemp == 0)
//        newTemp = c;
//      else
//        newFanSpeed = c;
//    }
//    
//    if (c == '*' && !recording) {
//      recording = true;
//    }
//  }
//  if (newTemp > 0) {
//    if (newTemp != temp || newFanSpeed != fanSpeed) {
//    Serial.print("New values: ");
//    Serial.print(newTemp, DEC);
//    Serial.print(" : ");
//    Serial.println(newFanSpeed, DEC);
//    
//      temp = newTemp;
//      fanSpeed = newFanSpeed;
//      updateAC(temp, fanSpeed);
//    }
//  }

  // polling interval
//  if (millis() - lastConnectionTime > pollingInterval) {
//    Serial.println("polling...");
//    client.stop();
    if (!client.connect(serverUrl, PORT)) {
      digitalWrite(LED_INFO, LOW); // show lost connection visually
    } else {
      // read values
      float humd = humidity.readHumidity();
      float temp = humidity.readTemperature();
      temp = temp * (9/5.0) + 32;
      
      Serial.print("temp: ");
      Serial.println(temp, 1);
      Serial.print("humid: ");
      Serial.println(humd, 1);

      // start request for settings
//      client.println("GET /settings HTTP/1.1");
//      client.println("Connection: close");
//
//      client.println();
//              delay(2000);
    

      client.print("PUT /record?temp=");
      client.print(temp, 1);
      client.print("&humd=");
      client.print(humd, 1);
      client.println(" HTTP/1.0");
      client.println();
      
    }
//    lastConnectionTime = millis();
//  }
}

/*==== AC INTERFACE ====*/
void pulseIR(long usecs) {
  cli();  // disable interrupts
 
  while (usecs > 0) {
    // 38 kHz is about 13 microseconds high and 13 microseconds low
   digitalWrite(IR_OUT, HIGH);  // this takes about 3 microseconds to happen
   delayMicroseconds(10);         // hang out for 10 microseconds, you can also change this to 9 if its not working
   digitalWrite(IR_OUT, LOW);   // this also takes about 3 microseconds
   delayMicroseconds(10);         // hang out for 10 microseconds, you can also change this to 9 if its not working
 
   // so 26 microseconds altogether
   usecs -= 26;
  }
 
  sei();
}

void sendIRByte(byte bite) {
  // send data one byte at a time MSB first
  for (int i = 0; i < 8; i++) {
    // 16 cycles ON * 26.3 = 420
    pulseIR(420);
    
    // 0: 46 cycles OFF * 26.3 = 1200
    // 1: 16 cycles OFF * 26.3 = 420
    uint16_t usec = bite & _BV(i) ? 1200 : 420;
    delayMicroseconds(usec);
  }
}

// temp: 64-88deg (will cap)
// fanSpeed: 0 - auto, 1 - high, 2 - med, 3 - low, 4 - quiet
void updateAC(byte temp, byte fanSpeed) {
  // http://old.ercoupe.com/audio/FujitsuIR.pdf
  // I'm using opposite endianess from this guide
  // carrier frequency: 38kHz 
  // carrier period: 26.3uSec
  
  // LEADER - start communication
  // 125 cycles carrier on
  // 62 cycles carrier off
  pulseIR(3288); // 125 * 26.3 = ~3288
  delayMicroseconds(1630); // 62 * 26.3 = ~1630
  
  // marker code (5 bytes)
  sendIRByte(0x14);
  sendIRByte(0x63);
  sendIRByte(0x00);
  sendIRByte(0x10);
  sendIRByte(0x10); // full command mode
  
  // always same
  sendIRByte(0xFE);
  sendIRByte(0x09);
  sendIRByte(0x30);
  
  // temperature
  // 64=0x2 --- 88=0xE
  temp = ((temp-64)/2) + 0x2;
  if (temp < 0x2)
    temp = 0x2;
  if (temp > 0xE)
    temp = 0xE;
  temp <<= 4;
  sendIRByte(temp);

  // timer
  sendIRByte(0x01);
  
  // swing/fan speed
  sendIRByte(fanSpeed);
  
  // timer toggle
  sendIRByte(0x0);
  sendIRByte(0x0);
  sendIRByte(0x0);
  // unknown
  sendIRByte(0x20);

  // checksum
  // sum of words 8 to 16 == 0xXX00 (mod 256 == 0)
  uint8_t sum = (0x20 + fanSpeed + 0x01 + temp + 0x30) % 256;
  sendIRByte(256 - sum);
  
  // TRAILER
  // 16 cycles carrier on
  // at least 305 cycles carrier off
  pulseIR(420); // 16 * 26.3 = 420
  delayMicroseconds(8000); // 305 * 26.3 = ~8000
}
