#include "HTU21D.h"

HTU21D htu = HTU21D();

void setup() {
	Serial.begin(9600);
	Serial.println("HTU21D test");

	while(! htu.begin()){
	    Serial.println("HTU21D not found");
	    delay(1000);
	}

	Serial.println("HTU21D OK");
}

void loop() {
	Serial.println("===================");
	Serial.print("Hum:"); Serial.println(htu.readHumidity());
	Serial.print("Temp:"); Serial.println(htu.readTemperature());
	Serial.println();

	delay(1000);
}


/*
#include <ESP8266WiFi.h>
#include <Wire.h>
#include <SparkFunHTU21D.h>

#define LED_INFO     5
#define IR_OUT       4


WiFiClient client;
HTU21D humidity;

unsigned long connectionRequestStartTime = 0; // last time you connected to the server, in milliseconds
const unsigned long connectionRequestTimeout = 10L * 1000L; // delay between updates, in milliseconds

void setup() {
  Serial.begin(9600);

  // LED INFO
  pinMode(LED_INFO, OUTPUT);
  digitalWrite(LED_INFO, LOW);

  // IR LED
  pinMode(IR_OUT, OUTPUT);

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
  digitalWrite(LED_INFO, HIGH);

  // POLL for AC settings change
  if (client.connect(serverUrl, PORT)) {
    // start request for settings
    client.println("GET /settings HTTP/1.1");
    client.println("Accept-Encoding: gzip, deflate");
    client.println("Connection: keep-alive");
    client.println("Host: temply.meteor.com:80");
    client.println();
    connectionRequestStartTime = millis();
    Serial.println("settings request sent");

    // poll client for response
    bool finished = false;
    while (!finished) {
      bool recording = false;
      byte newTemp = 0;
      byte newFanSpeed = 0;
      while (client.available()) {
        char c = client.read();
        Serial.print(c);

        if (c == '*' && recording) {
          recording = false;
          finished = true;
          continue; // allow client to consume remaining HTTP response
        }

        // server needs to send 4 byte data block = *AB* (A = temp, B = fanSpeed)
        if (recording) {
          if (newTemp == 0)
            newTemp = c;
          else
            newFanSpeed = c;
        }

        if (c == '*' && !recording) {
          recording = true;
        }
      }

      if (finished) {
        changeACSettings(newTemp, newFanSpeed);
        break;
      }

      delay(100);

      if (millis() - connectionRequestStartTime > connectionRequestTimeout) {
        Serial.println("response timed out");
        break; // timeout response handling
      }
    }
    client.stop();
  } else {
    digitalWrite(LED_INFO, LOW);
  }

  delay(6000); // seperate POLL and PUSH

  if (client.connect(serverUrl, PORT)) {
    // read values
    float humd = humidity.readHumidity();
    float temp = humidity.readTemperature();
    temp = temp * (9/5.0) + 32;

    Serial.print("temp: ");
    Serial.println(temp, 1);
    Serial.print("humid: ");
    Serial.println(humd, 1);

    client.print("PUT /record?temp=");
    client.print(temp, 1);
    client.print("&humd=");
    client.print(humd, 1);
    client.println(" HTTP/1.1");
    client.println("Accept-Encoding: gzip, deflate");
    client.println("Connection: keep-alive");
    client.println("Content-Length: 0");
    client.println("Host: temply.meteor.com:80");
    client.println();
  } else {
    digitalWrite(LED_INFO, LOW);
  }

  delay(6000); // seperate POLL and PUSH
}
*/
/*==== AC INTERFACE ====*/
/*
// default AC status
int temp = 0;
int fanSpeed = 0;

void changeACSettings(byte newTemp, byte newFanSpeed) {
  Serial.print("New values: ");
  Serial.print(newTemp, DEC);
  Serial.print(" : ");
  Serial.println(newFanSpeed, DEC);

  if (newTemp != temp || newFanSpeed != fanSpeed) {
    temp = newTemp;
    fanSpeed = newFanSpeed;
    updateAC(temp, fanSpeed);
  }
}

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
*/
