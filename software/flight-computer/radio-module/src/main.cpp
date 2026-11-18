#include <Arduino.h>
#include <RadioLib.h>

static const uint32_t LED = PB5;

STM32WLx radio = new STM32WLx_Module();

// Wio-E5 mini: RX = PA4 high / PA5 low, TX (HP only) = PA4 low / PA5 high
static const uint32_t rfswitch_pins[] =
                         {PA4, PA5, RADIOLIB_NC, RADIOLIB_NC, RADIOLIB_NC};
static const Module::RfSwitchMode_t rfswitch_table[] = {
  {STM32WLx::MODE_IDLE,  {LOW,  LOW}},
  {STM32WLx::MODE_RX,    {HIGH, LOW}},
  {STM32WLx::MODE_TX_HP, {LOW,  HIGH}},   // no TX_LP: module only has the HP path
  END_OF_MODE_TABLE,
};

volatile bool rxFlag = false;
void onRx(void) { rxFlag = true; }

uint32_t nextTx = 0;
uint32_t lastStatus = 0;
uint32_t counter = 0;
uint32_t myId;

void setup() {
  pinMode(LED, OUTPUT);
  Serial.begin(115200);
  delay(3000);   // lets the monitor attach so you see the boot lines

  myId = HAL_GetUIDw0() ^ HAL_GetUIDw1() ^ HAL_GetUIDw2();
  randomSeed(myId);
  Serial.print(F("Board ID: ")); Serial.println(myId, HEX);

  radio.setRfSwitchTable(rfswitch_pins, rfswitch_table);

  ConfigLoRa_t config;
  config.frequency = RADIOLIB_UNIT_MEGA(868);
  radio.tcxoVoltage = RadioLibTCXOVoltage_t::Voltage1V7;

  Serial.print(F("begin: "));
  int state = radio.begin(config);
  Serial.println(state);                       // 0 = OK
  if (state != RADIOLIB_ERR_NONE) {
    while (true) { digitalWrite(LED, !digitalRead(LED)); delay(100); }
  }

  state = radio.setOutputPower(15);            // above 14 dBm -> HP path
  Serial.print(F("setOutputPower: ")); Serial.println(state);

  radio.setDio1Action(onRx);
  state = radio.startReceive();
  Serial.print(F("startReceive: ")); Serial.println(state);

  nextTx = millis() + random(1000, 4000);
}

void loop() {
  // Incoming packet
  if (rxFlag) {
    rxFlag = false;
    String str;
    int state = radio.readData(str);
    if (state == RADIOLIB_ERR_NONE) {
      Serial.print(F("RX '")); Serial.print(str);
      Serial.print(F("'  RSSI ")); Serial.print(radio.getRSSI(), 1);
      Serial.print(F(" dBm  SNR ")); Serial.print(radio.getSNR(), 1);
      Serial.println(F(" dB"));
      digitalWrite(LED, !digitalRead(LED));
    } else {
      Serial.print(F("RX error ")); Serial.println(state);
    }
    radio.startReceive();
  }

  // Periodic transmit
  if (millis() >= nextTx) {
    String msg = String(myId, HEX) + " #" + String(counter++);
    Serial.print(F("TX '")); Serial.print(msg); Serial.print(F("' -> "));
    int state = radio.transmit(msg);
    Serial.println(state);                     // 0 = sent
    radio.startReceive();                      // back to listening
    rxFlag = false;                            // ignore any TX-done interrupt
    nextTx = millis() + random(3000, 6000);
  }

  // So the monitor is never silent
  if (millis() - lastStatus > 5000) {
    lastStatus = millis();
    Serial.println(F("... listening"));
  }
}