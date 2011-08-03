#include <SPI.h>
#include "common.h"
#include "Mirf.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"

#define LED1 0
//#define LED2 3
//#define LED3 5

#define SWITCH 2
int stateSwitch = LOW;

#define POTAR_X 0
#define POTAR_Y 1
int potarValueX = 0;
int potarValueY = 0;
#define POTAR_SWITCH 4
int potarSwitch = LOW;

void ledfeedback();
void triggerPad();
void readPotar();

void setup()
{
  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = CE;
  Mirf.csnPin = CSN;
  Mirf.init();
  Mirf.setTADDR(ADDR);
  Mirf.payload = PAYLOAD;
  Mirf.config();

  pinMode(LED1, OUTPUT);
  //pinMode(LED2, OUTPUT);
  //pinMode(LED3, OUTPUT);
  //pinMode(SWITCH, INPUT);
  //pinMode(POTAR_X, INPUT);
  //pinMode(POTAR_Y, INPUT);
  //pinMode(POTAR_SWITCH, INPUT);
  //digitalWrite(LED1, HIGH);
}

void loop()
{
  static uint8_t buf[PAYLOAD];
  static uint8_t previousState = 0;
  uint8_t currentState = stateSwitch;
  static int i = 0;

  triggerPad();
  readPotar();

  buf[0] = stateSwitch == HIGH ? 1 : 0;
  //buf[1] = potarSwitch == LOW ? 1 : 0;
  //buf[2] = (uint8_t)potarValueX;
  //buf[3] = (uint8_t)(potarValueX >> 8);
  //buf[4] = (uint8_t)potarValueY;
  //buf[5] = (uint8_t)(potarValueY >> 8);

  Mirf.send(buf);
  while(Mirf.isSending());

  delay(100);
}

void triggerPad()
{
  stateSwitch = stateSwitch == HIGH ? LOW : HIGH; //digitalRead(SWITCH);

  if (stateSwitch == HIGH)
    digitalWrite(LED1, HIGH);
  else
    digitalWrite(LED1, LOW);
}

void readPotar()
{
  //potarValueX = analogRead(POTAR_X);
  //potarValueY = analogRead(POTAR_Y);
  //potarSwitch = digitalRead(POTAR_SWITCH);
  //
  //if (potarSwitch == LOW)
  //  analogWrite(LED1, 255);
  //else
  //  analogWrite(LED1, 0);
  //
  //analogWrite(LED2, potarValueX / 4);
  //analogWrite(LED3, potarValueY / 4);
}
