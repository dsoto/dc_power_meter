this circuit implements a DC power meter to measure the consumption
of microcontrollers and modems.  the range of measurement is less than
1 watt with currents up to 200mA at 5V.

the current will be sensed by a 0.5 ohm resistor and a current sense
amplifier with a gain of 50V/V.  thus, a 200mA current through the shunt
will yield a voltage at the atmel ADC pin of 5V.

the voltage will be divided by a voltage divider with a gain of 0.5.

the program psuedocode is

read ADC values
multiply ADC values by conversion factors
report engineering units for current and voltage to LCD and serial
multiply to get power
report power to LCD and serial
