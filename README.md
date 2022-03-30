# digital-signal-filter
This is a digital signal filter written in VHDL for a Basys3 fpga board, and interfaced through a simple Java program.

## How to use:
1. Program your Basys board with the provided VHDL code, and run the implementation.
2. Run the Java program (the COM interface may differ).
3. Press either S or W for selecting a sine wave or, a sawtooth wave respectively.
4. To activate a filter, simply activate the associated switch on the Basys board.

### The filters:
_Low pass FIR filter:_
[filter1](https://github.com/DudasDorian/digital-signal-filter/blob/main/filter1.png)

_Binary filter (0 when input signal <0; 127 when input signal >=0)_
[filter2](https://github.com/DudasDorian/digital-signal-filter/blob/main/filter2.png)
