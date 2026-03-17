module mp_risc_tb_1;
reg clk1, clk2;
integer k;
mp_risc mips (clk1, clk2);
// Generating two-phase clock
initial
begin
clk1 = 0; clk2 = 0;
repeat (20)
begin
#5 clk1 = 1; #5 clk1 = 0; // Positive-edge clock1, negative-edge clock1
#5 clk2 = 1; #5 clk2 = 0; // Positive-edge clock2, negative-edge clock2
end
end
// Initializing the MIPS processor memory and registers
initial
begin
for (k=0; k<31; k=k+1)
mips.Reg[k] = k; // Assigning values to general-purpose registers
mips.Mem[200] = 32'h00000005; // Memory location 200 initialized with 5
mips.Mem[0] = 32'h00c80810; // Memory location 0 initialized with instruction (LW R1,00C8)
mips.Mem[1] = 32'h000739c5; // Memory location 1 initialized with instruction (OR R7,R7,R7)---DUMMY VARIABLE
mips.Mem[2] = 32'h000739c5; // Memory location 2 initialized with instruction (OR R7,R7,R7)---DUMMY VARIABLE
mips.Mem[3] = 32'h000a1041; // Memory location 3 initialized with instruction (ADDI R2,R1,000A)
mips.Mem[4] = 32'h00041841; // Memory location 4 initialized with instruction (ADDI R3,R1,0004)
mips.Mem[5] = 32'h000739c5; // Memory location 5 initialized with instruction (OR R7,R7,R7)---DUMMY VARIABLE
mips.Mem[6] = 32'h000739c5; // Memory location 6 initialized with instruction (OR R7,R7,R7)---DUMMY VARIABLE
mips.Mem[7] = 32'h00011889; // Memory location 7 initialized with instruction (SLT R1,R2,R3)
mips.Mem[8] = 32'h0004188b; // Memory location 8 initialized with instruction (MUL R4,R2,R3)
mips.Mem[9] = 32'h00051884; // Memory location 9 initialized with instruction (AND R5,R2,R3)
mips.Mem[10] = 32'h0001188c; // Memory location 10 initialized with instruction (SLL R1,R2)
mips.Mem[11] = 32'h00041893; // Memory location 11 initialized with instruction (SNEQ R4,R2,R3)
mips.Mem[12] = 32'h00051886; // Memory location 12 initialized with instruction (XOR R5,R2,R3)
mips.Mem[13] = 32'h00110888; // Memory location 13 initialized with instruction (ORI R1,R2,0001)
mips.Mem[14] = 32'h00c91011; // Memory location 14 initialized with instruction (SW R2,00C9)
mips.Mem[15] = 32'h00ca1811; // Memory location 15 initialized with instruction (SW R3,00CA)
mips.Mem[16] = 32'h0000003f; // Memory location 16 initialized with instruction (HALT)
mips.HALTED = 0; // Initialize HALTED signal to 0 (not halted)
mips.PC = 0; // Initialize program counter (PC) to 0
mips.TAKEN_BRANCH = 0; // Initialize TAKEN_BRANCH signal to 0
#280
for (k=0; k<6; k=k+1)
$display ("R%1d - %2d", k, mips.Reg[k]); // Display the initial values of some registers
end
initial
begin
$dumpfile ("mips.vcd"); // Define VCD dumpfile
$dumpvars (0, mp_risc_tb_1); // Dump variables for VCD
#300 $finish; // Finish the simulation after some delay
end
endmodule
ASSEMBLY LANGUAGE PROGRAM:
LW R1,00C8;
ADDI R2,R1,000A;
ADDI R3,R1,0004;
SLT R1,R2,R3;
MUL R4,R2,R3;
AND R5,R2,R3;
SLL R1,R2;
SNEQ R4,R2,R3;
XOR R5,R2,R3;
ORI R1,R2,0001;
SW R2,00C9;
SW R3,00CA;
HLT