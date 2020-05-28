# Centauri_FPGA_Challenge
Preamble detection code developed on Quartus Prime and simulated on ModelSim

Purpose: Code was developed to meet the problem statement below.

FPGA Challenge Problem:

You have been given a mystery machine which uses an FPGA to control its functions. You will be
required to design and develop the Verilog/VHDL code for control of these functions.
The machine uses an input clock operating at 100MHz, 50% duty cycle. The user must press a button
to start the mystery box operations. When the start button is pressed, a light is illuminated (assume it
is digitally controlled by an io pin on the FPGA, don’t worry about the circuit involved). In addition,
once the start button is pressed, the machine will begin analyzing the input wire to detect a
preamble coming in over the wire. Upon detecting the preamble, the machine must rotate a servo
with a flag attached from its starting position clockwise 90 degrees to a vertical position. This flag
remains up for 10 seconds after which the whole system must reset, awaiting the start button press.
Please draw a state machine of the system and write out the implementation in VHDL or
Verilog. Do not worry about a pin connection file.

Assume the inputs to the system are the following:
 clk_in: the previously mentioned clock
 button: the start button, (on or off)
 data_line: constant data where the preamble must be detected (wire)
 led: toggles an LED (on or off)
 servo: controls the PWM for the servo holding the flag

Please note that the servo operates with a period of 20ms, the starting position requires a duty cycle
of 1.0 ms and the up position requires a duty cycle of 1.5 ms
The following figure describes the preamble:
