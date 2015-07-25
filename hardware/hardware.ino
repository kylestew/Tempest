#include <ESP8266WiFi.h>
#include <Wire.h>
#include <SparkFunHTU21D.h>

/* Wifi */
const char* ssid = "monkey_island";
const char* password = "monkeybusine$$";

/* Server API */
const char* serverUrl = "192.168.0.11";

/* Pins */
/* HOOKUP GUIDE
  3V -- 10k -- AL(0)  <-- pull up AL0
*/
const int LED_PIN = 5;
const int SPEAKER = 4;
const int AL = 13;

HTU21D humidity;

void setup() {
  Serial.begin(9600);
  // LED
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);
  // SPEAKER
  pinMode(SPEAKER, OUTPUT);
  digitalWrite(SPEAKER, LOW);
  // PIR AL
  pinMode(AL, INPUT);
  
  humidity.begin();

  // boot up wifi
  byte ledStatus = LOW;
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.mode(WIFI_STA); // connect to local wifi, don't make an access point
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    // Blink the LED
    digitalWrite(LED_PIN, ledStatus); // Write LED high/low
    ledStatus = (ledStatus == HIGH) ? LOW : HIGH;
    
    // blocking loops will cause SOC to reset
    delay(100);
    Serial.print(".");
  }
  digitalWrite(LED_PIN, HIGH);
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}

void loop()  {
  delay(1000);
  digitalWrite(LED_PIN, LOW);
  delay(1000);
  
  WiFiClient client;
  if (!client.connect(serverUrl, 3000)) {
    beep(1000); // annoy me when I lose connection
  } else {
    // read values
    float humd = humidity.readHumidity();
    float temp = humidity.readTemperature();
    temp = temp * (9/5.0) + 32;
    int pir = digitalRead(AL);
      
    client.print("PUT /record?temp=");
    client.print(temp, 1);
    client.print("&humd=");
    client.print(temp, 1);
    client.print("&motion=");
    client.print(pir);
    client.println(" HTTP/1.0");
    client.println();
        
    digitalWrite(LED_PIN, HIGH);
  }
}

void beep(unsigned char delayms){
  analogWrite(SPEAKER, 20);      // Almost any value can be used except 0 and 255
                           // experiment to get the best tone
  delay(delayms);          // wait for a delayms ms
  analogWrite(SPEAKER, 0);       // 0 turns it off
  delay(delayms);          // wait for a delayms ms   
}
