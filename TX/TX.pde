#include <SPI.h>
#include "common.h"
#include "Mirf.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"

#define DEBUG_LED
#define JOY_X 16
#define JOY_Y 17
#define N_PADS 4

typedef enum {
  PAD1 = 18,
  PAD2 = 19,
  PAD3 = 20,
  PAD4 = 21,
} pads_t;

bool padsPressed = false;
bool padsStates[N_PADS] = {false};
bool joyPressed = true;
uint16_t joyValX = 0;
uint16_t joyValY = 0;

void hello();
void readPads();
void readJoy();

void setup()
{
  // with a 3.3V supply we need 8MHz instead of 16MHz
  SET_CPU_FREQ;

  Serial.begin(115200);

  pinMode(LED, OUTPUT);
  hello();

  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = CE;
  Mirf.csnPin = CSN;
  Mirf.init();
  Mirf.setTADDR((byte*)ADDR);
  Mirf.payload = PAYLOAD;
  Mirf.config();
}

void loop()
{
  static uint8_t buf[PAYLOAD];

  readPads();
  for (int i = 0; i < N_PADS; i++)
    buf[i] = padsStates[i] ? 1 : 0;

  readJoy();
  buf[N_PADS + 0] = (uint8_t)(joyValX >> 0);
  buf[N_PADS + 1] = (uint8_t)(joyValX >> 8);
  buf[N_PADS + 2] = (uint8_t)joyValY;

#ifdef DEBUG_LED
  if (padsPressed || joyPressed)
    digitalWrite(LED, HIGH);
  else
    digitalWrite(LED, LOW);
#endif

  Mirf.send(buf);
  while(Mirf.isSending());
}

void readPads()
{
  padsPressed = false;
  for (int i = 0; i < N_PADS; i++)
  {
    if(digitalRead(PAD1 + i) == HIGH)
    {
      padsStates[i] = true; //switch the led on only if one of the state was high
      padsPressed = true;
    }
    else
      padsStates[i] = false;
  }
}

void readJoy()
{
  uint16_t newJoyValX = 16383 - analogRead(JOY_X) * (16384 / 1023);
  uint16_t newJoyValY = ABS(((analogRead(JOY_Y) >> 2) - 127));
  newJoyValY = newJoyValY > 127 ? 127 : newJoyValY;
  
  joyPressed = false;
  
  if (ABS(joyValX - newJoyValX) > (1 << 5))
  {
    joyValX = newJoyValX;
    joyPressed = true;
  }
  
  if (ABS(joyValY - newJoyValY) > (1 << 3))
  {
    joyValY = newJoyValY;
    joyPressed = true;
  }
}

void hello()
{
  for (int i = 0; i < 6; i++)
  {
    digitalWrite(LED, HIGH);
    delay(50);
    digitalWrite(LED, LOW);
    delay(100);
  }
}

