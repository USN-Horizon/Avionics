#pragma once

#include <cstddef>
#include <utility>
#include <vector>

#include "sensors/i_sensor.hpp"

// A sensor that replays a list of readings written by hand.
// Every call to read() returns the next reading in the list.
// When the list runs out, read() returns an invalid Reading,
// like a sensor that stopped responding.
class ReplaySensor : public ISensor {
public:
    // Takes the list of readings this sensor will return, in order.
    ReplaySensor(std::vector<Reading> samples) {
        samples_ = std::move(samples);
    }

    Reading read() override {
        if (next_ < samples_.size()) {
            // Return the current reading, then move on to the next one.
            return samples_[next_++];
        } else {
            // No readings left. A default Reading has valid = false.
            return Reading{};
        }
    }

private:
    std::vector<Reading> samples_;  // all the readings to replay
    std::size_t next_ = 0;          // position of the next reading to return
};
