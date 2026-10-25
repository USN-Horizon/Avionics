#pragma once

// One measurement. A driver must set valid = false when the sensor failed or
// timed out; callers must not use value in that case.
struct Reading {
    double value = 0.0;
    bool valid = false;
};

// Abstract sensor: the rest of the code talks to this interface only, so a
// real hardware driver or a fake can be swapped in without changing callers.
class ISensor {
public:
    virtual ~ISensor() = default;
    virtual Reading read() = 0;
};
