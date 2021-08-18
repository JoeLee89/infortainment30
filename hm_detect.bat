:: SA3X
:: Hard Meter Detection Control Flow:
:: 1. Write(0x24C,0x80000000) //start detection
:: 2. Check 0x248 bit2 until the flag goes down to 0
:: 3. Read(0x24C) //bit15~0 are present flags for all channels

FPGA_SetL.exe 0x24C 0x80000000
timeout 1
FPGA_GetL.exe 0x24C
