#include <SPI.h>
#include "common.h"
#include "Mirf.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"

#define LED     11
#define CHANNEL 16

void hello();

// with a 3.3V supply we need 8kHz instead of 16kHz...
#define CPU_PRESCALE(n) (CLKPR = 0x80, CLKPR = (n))

void setup()
{
  CPU_PRESCALE(0x01); // ...we also have to edit the Makefile

  pinMode(LED, OUTPUT);
//  for(;;) //test
  hello();

  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = CE;
  Mirf.csnPin = CSN;
  Mirf.init();
  Mirf.setRADDR(ADDR);
  Mirf.payload = PAYLOAD;
  Mirf.config();
}

void loop()
{
  static uint8_t buf[PAYLOAD];
  static int state[4] = {0};
  static int note[4] = {42, 43, 44, 45};
  static int lastPitch = 0;
  int pitch_x, pitch_y;
  char accu =0;

  if(Mirf.dataReady())
  {
    Mirf.getData(buf);

    for (int i = 0; i < 3; i++) // 4 pads
    {
      if (buf[i])
      {
        if (state[i] == 0)
        {
          usbMIDI.sendNoteOn(note[i], 255, CHANNEL);
          state[i] = 1;
        }
      }
      else
      {
        if (state[i] == 1)
        {
          usbMIDI.sendNoteOff(note[i], 0, CHANNEL);
          state[i] = 0;
        }
      }
      accu |= state[i];
    }
    digitalWrite(LED, accu); //switch the led on only if one of the state was high

    pitch_x = buf[4] * 0x4000 / 256 - 0x2000;
    pitch_y = buf[5] * 0x4000 / 256 - 0x2000;

    //if (pitch != lastPitch)
    //{
    usbMIDI.sendPitchBend(pitch_x, 1);
    usbMIDI.sendPitchBend(pitch_y, 1);
    //}

    //lastPitch = pitch;

    Mirf.flushRx();
  }
}

void hello()
{
  for (int i=0; i<9; i++)
  {
    usbMIDI.sendNoteOn(42 + i, 255, CHANNEL);
    digitalWrite(LED, HIGH);
    delay(100);
    usbMIDI.sendNoteOff(42 + i, 255, CHANNEL);
    digitalWrite(LED, LOW);
    delay(50);
  }
}
