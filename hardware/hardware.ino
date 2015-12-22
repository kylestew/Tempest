#include "HTU21D.h"

#define LED_INFO     D7
#define IR_OUT       D2

HTU21D htu = HTU21D();

double humd = 0;
double temp = 0;

void setup() {
	Serial.begin(9600);

  pinMode(LED_INFO, OUTPUT);
  pinMode(IR_OUT, OUTPUT);

	// connect to I2C temp
	while(! htu.begin()){
	    Serial.println("HTU21D not found");
	    delay(1000);
	}

	// track variables
	Particle.variable("humd", humd);
	Particle.variable("temp", temp);

	// setup IR function
	Particle.function("writeTo", updateThermostat);
	Particle.function("turnOff", turnOff);
}

void loop() {
	// poll current temp values
	humd = htu.readHumidity();
	temp = htu.readTemperature();
	delay(1000);
}

int updateThermostat(String command) {
	/* FORMAT: 1 byte per value
	  MASTER|TEMP|FANSPEED
	*/

	Serial.println(command);

	// parse into components
	int idx0 = command.indexOf(',');
	int idx1 = command.indexOf(',', idx0+1);
	int idx2 = command.indexOf(',', idx1+1);
	int master = atoi(command.substring(0,idx0));
	int temp = atoi(command.substring(idx0+1,idx1));
	int fanSpeed = atoi(command.substring(idx1+1,idx2));

	/*if (master == 0) {
		Serial.println("master");
	}
	if (temp == 80) {
		Serial.println("temp");
	}
	if (fanSpeed == 2) {
		Serial.println("fanSpeed");
	}*/

  updateAC(master, temp, fanSpeed);

	return 0;
}

/*==== AC INTERFACE ====*/
void pulseIR(long usecs) {
	noInterrupts(); // disable interrupts

  while (usecs > 0) {
    // 38 kHz is about 13 microseconds high and 13 microseconds low
   digitalWrite(IR_OUT, HIGH);  // this takes about 3 microseconds to happen
   delayMicroseconds(10);         // hang out for 10 microseconds, you can also change this to 9 if its not working
   digitalWrite(IR_OUT, LOW);   // this also takes about 3 microseconds
   delayMicroseconds(10);         // hang out for 10 microseconds, you can also change this to 9 if its not working

   // so 26 microseconds altogether
   usecs -= 26;
  }

	interrupts();
}

void sendIRByte(byte bite) {
  // send data one byte at a time MSB first
  for (int i = 0; i < 8; i++) {
    // 16 cycles ON * 26.3 = 420
    pulseIR(420);

    // 0: 46 cycles OFF * 26.3 = 1200
    // 1: 16 cycles OFF * 26.3 = 420
    uint16_t usec = bite & 0x00000001 ? 1200 : 420;
		bite = bite >> 1;
    delayMicroseconds(usec);
  }
}

// masterControl: 0 - auto, 1 - cool, 2 - dry, 3 - fan, 4 - heat
// temp: 64-88deg (will cap)
// fanSpeed: 0 - auto, 1 - high, 2 - med, 3 - low, 4 - quiet
void updateAC(byte masterControl, byte temp, byte fanSpeed) {
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

  // timer/master control
  sendIRByte(masterControl);

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
  uint8_t sum = (0x20 + fanSpeed + masterControl + temp + 0x30) % 256;
  sendIRByte(256 - sum);

  // TRAILER
  // 16 cycles carrier on
  // at least 305 cycles carrier off
  pulseIR(420); // 16 * 26.3 = 420
  delayMicroseconds(8000); // 305 * 26.3 = ~8000
}

int turnOff(String command) {
	// 0 0 1 0 1 0 0 0 - 1 1 0 0 0 1 1 0 - 0 0 0 0 0 0 0 0 - 0 0 0 0 1 0 0 0 - 0 0 0 0 1 0 0 0 - 0 1 0 0 0 0 0 0 - 1 0 1 1 1 1 1 1
  // LEADER - start communication
  // 125 cycles carrier on
  // 62 cycles carrier off
  pulseIR(3288); // 125 * 26.3 = ~3288
  delayMicroseconds(1630); // 62 * 26.3 = ~1630

  sendIRByte(0x14);
  sendIRByte(0x63);
  sendIRByte(0x00);
  sendIRByte(0x08);
  sendIRByte(0x08);
  sendIRByte(0x02);
  sendIRByte(0xFD);

  // TRAILER
  // 16 cycles carrier on
  // at least 305 cycles carrier off
  pulseIR(420); // 16 * 26.3 = 420
  delayMicroseconds(8000); // 305 * 26.3 = ~8000

	return 0;
}
