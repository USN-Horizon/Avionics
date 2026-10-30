#pragma once

#include "sensors/replay_sensor.hpp"

// Simulated sensors for testing on the PC. Each one is a ReplaySensor with a
// short list of made-up readings, one per second of a pretend flight:
// launch, boost, coast, and the start of the descent.
//
// Each reading is written as {value, valid}. valid = true means the sensor
// worked; valid = false means it failed and the value must not be used.

// Altitude above the launch pad, in metres.
class SimulatedAltitudeSensor : public ReplaySensor {
public:
    SimulatedAltitudeSensor()
        : ReplaySensor({
              {0.0, true},    // on the pad
              {50.0, true},
              {200.0, true},
              {450.0, true},  // highest point
              {400.0, true},  // falling
          }) {}
};

// Vertical speed in metres per second. Positive is up, negative is down.
class SimulatedVelocitySensor : public ReplaySensor {
public:
    SimulatedVelocitySensor()
        : ReplaySensor({
              {0.0, true},
              {90.0, true},
              {150.0, true},  // fastest
              {10.0, true},
              {-20.0, true},  // falling
          }) {}
};

// Acceleration in metres per second squared.
// -9.8 is just gravity: the engine has burned out.
class SimulatedAccelerationSensor : public ReplaySensor {
public:
    SimulatedAccelerationSensor()
        : ReplaySensor({
              {30.0, true},  // engine burning
              {70.0, true},
              {-9.8, true},  // engine off
              {-9.8, true},
              {-9.8, true},
          }) {}
};

// Rotation speed in degrees per second.
// The third reading is marked invalid on purpose, to show that the code
// reading the sensor must check `valid` before using the value.
class SimulatedGyroscope : public ReplaySensor {
public:
    SimulatedGyroscope()
        : ReplaySensor({
              {0.0, true},
              {1.5, true},
              {0.0, false},  // sensor failed, the 0.0 means nothing
              {-2.0, true},
              {0.5, true},
          }) {}
};

// The GPS gives only one number for now: the horizontal distance from the
// launch pad, in metres. A real GPS would give latitude, longitude and altitude.
class SimulatedGps : public ReplaySensor {
public:
    SimulatedGps()
        : ReplaySensor({
              {0.0, true},
              {2.0, true},
              {10.0, true},
              {25.0, true},
              {40.0, true},
          }) {}
};
