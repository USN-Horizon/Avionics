#include <iomanip>
#include <iostream>

#include "sensors/sensor_simulators.hpp"

int main() {
    SimulatedAltitudeSensor altitude;
    SimulatedVelocitySensor velocity;
    SimulatedAccelerationSensor acceleration;
    SimulatedGyroscope gyroscope;
    SimulatedGps gps;

    // Display sensor readings in fixed-point notation with one digit after the decimal.
    std::cout << std::fixed << std::setprecision(1);

    std::cout << "  t[s]  alt[m]  vel[m/s]  acc[m/s2]  gyro[deg/s]  gps_range[m]\n";

    // One loop iteration = one second. The simulators hold 5 samples each.
    for (int t = 0; t < 5; ++t) {
        const Reading altR = altitude.read();
        const Reading velR = velocity.read();
        const Reading accR = acceleration.read();
        const Reading gyroR = gyroscope.read();
        const Reading rangeR = gps.read();

        if (!(altR.valid && velR.valid && accR.valid && gyroR.valid && rangeR.valid)) {
            std::cout << std::setw(6) << t << "  bad reading, skipped\n";
            continue;
        }

        // setw sets each column's minimum width; values use fixed notation with one decimal place.
        std::cout << std::setw(6) << t << std::setw(8) << altR.value << std::setw(10) << velR.value
                  << std::setw(11) << accR.value << std::setw(13) << gyroR.value << std::setw(14)
                  << rangeR.value << "\n";
    }
    return 0;
}
